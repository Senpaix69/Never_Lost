import 'dart:async' show StreamController;
import 'dart:convert' show jsonDecode, jsonEncode, utf8;
import 'dart:io' show File;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:neverlost/contants/firebase_contants/firebase_contants.dart';
import 'package:neverlost/services/firebase_auth_services/fb_user.dart';
import 'package:neverlost/services/note_services/note.dart';
import 'package:neverlost/services/note_services/todo.dart';
import 'package:neverlost/services/notification_service.dart';
import 'package:neverlost/services/timetable_services/timetable.dart';
import 'package:neverlost/utils.dart';
import 'package:path/path.dart' show basename;
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neverlost/services/firebase_auth_services/auth_errors.dart';
import 'package:uuid/uuid.dart';

enum SPActions {
  set,
  get,
  delete,
}

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  FBUser? _user;
  Map<String, String>? _restore;

  FBUser? get user => _user;
  Future<Map<String, String>?> get restoreBackupSize async {
    _restore ??= await spRestoreSize(action: SPActions.get);
    return _restore;
  }

  // Stream controller for user data
  final StreamController<Object?> _userController =
      StreamController<Object?>.broadcast();

  // Getter for the user data stream
  Stream<Object?> get userStream => _userController.stream;

  // Singleton pattern
  FirebaseService._privateConstructor();

  static final FirebaseService _instance =
      FirebaseService._privateConstructor();

  factory FirebaseService.instance() => _instance;

  Future<void> setBackupToCloud() async {
    final collection = _firestore.collection(
      'users/${_user!.uid}/backupSize',
    );
    final data = {
      timetableColumn: "0.0 bytes",
      todoColumn: "0.0 bytes",
      noteColumn: "0.0 bytes",
    };
    final backUpSize = await collection.get().then((snap) => snap.docs);
    if (backUpSize.isEmpty) {
      await collection.doc(_user!.uid).set(data);
      await spRestoreSize(action: SPActions.set, size: data);
      return;
    }
    final doc = backUpSize.first.data();
    final restoreDataSize = {
      timetableColumn: doc[timetableColumn]! as String,
      todoColumn: doc[todoColumn]! as String,
      noteColumn: doc[noteColumn]! as String,
    };
    spRestoreSize(action: SPActions.set, size: restoreDataSize);
    _restore = restoreDataSize;
  }

  Future<AuthError?> loginWithEmailPassword({
    required String email,
    required String password,
    String? profilePicPath,
  }) async {
    await logOut();

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final fbuser = userCredential.user;
      setUser(fbuser!, profilePicPath);
      await setBackupToCloud();
      return null;
    } on FirebaseAuthException catch (e) {
      return AuthError.from(e);
    }
  }

  Future<AuthError?> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return AuthError.from(e);
    }
  }

  Future<AuthError?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    final userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    final fbuser = userCredential.user!;
    setUser(fbuser, null);

    await setBackupToCloud();
    return null;
  }

  // Create user
  Future<AuthError?> createUserWithEmailPassword({
    required String email,
    required String password,
    required String fullName,
    String? profilePicPath,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user!.uid;
      String? profilePic;
      if (profilePicPath != null) {
        final profilePicData = await _uploadProfilePicture(
          userId: userId,
          profilePicPath: profilePicPath,
        );
        await userCredential.user!
            .updatePhotoURL(profilePicData[userProfilePicURL]);
        profilePic = profilePicData[userProfilePic];
      }
      await userCredential.user!.updateDisplayName(fullName);
      await FirebaseAuth.instance.signOut();
      return loginWithEmailPassword(
        email: email,
        password: password,
        profilePicPath: profilePic,
      );
    } on FirebaseAuthException catch (e) {
      return AuthError.from(e);
    }
  }

  Future<void> uploadTodos({
    required List<Todo> todos,
    required CallbackAction? callback,
  }) async {
    bool isProgress = callback != null;
    int len = todos.length;
    double progress = 0.0;
    final collection = _firestore.collection(
      'users/${_user!.uid}/todos',
    );
    await deleteBackUp(collectionTable: "todos");
    for (int i = 0; i < len; i++) {
      if (isProgress) {
        progress = (i + 1) / len * 100;
        callback("Progress: ${progress.toStringAsFixed(2)}%");
      }
      final todo = todos[i].copyWith(reminder: 0);
      await collection.add(todo.toMap());
    }

    final backUpSizeCollection =
        _firestore.collection('users/${_user!.uid}/backupSize');
    String size = convertSizeUnit(size: calculateSize(list: todos));
    await backUpSizeCollection.doc(_user!.uid).set(
      {todoColumn: size},
      SetOptions(merge: true),
    );
    final getSize = await spRestoreSize(action: SPActions.get);
    spRestoreSize(action: SPActions.set, size: {
      todoColumn: size,
      timetableColumn: getSize![timetableColumn]!,
      noteColumn: getSize[noteColumn]!,
    });
  }

  Future<List<Todo>> getAllTodos() async {
    try {
      final querySnapshot = await _firestore
          .collection("users")
          .doc(_user!.uid)
          .collection("todos")
          .get();

      final allTodos =
          querySnapshot.docs.map((doc) => Todo.fromMap(doc.data())).toList();
      return allTodos;
    } catch (e) {
      return [];
    }
  }

  Future<void> uploadTimetables({
    required List<TimeTable> timetables,
    required CallbackAction? callback,
  }) async {
    bool isProgress = callback != null;
    int len = timetables.length;
    double progress = 0.0;
    final collection = _firestore.collection('users/${_user!.uid}/timetables');
    final backUpSizeCollection =
        _firestore.collection('users/${_user!.uid}/backupSize');

    await deleteBackUp(collectionTable: "timetables");

    for (int i = 0; i < len; i++) {
      if (isProgress) {
        progress = (i + 1) / len * 100;
        callback("Progress: ${progress.toStringAsFixed(2)}%");
      }
      final timetable = timetables[i];
      final sub = timetable.subject.copyWith(sched: 0);
      await collection.add(
        timetable.copyWith(subject: sub).toMap(),
      );
    }
    String size = convertSizeUnit(size: calculateSize(list: timetables));
    await backUpSizeCollection.doc(_user!.uid).set(
      {timetableColumn: size},
      SetOptions(merge: true),
    );
    final getSize = await spRestoreSize(action: SPActions.get);
    spRestoreSize(action: SPActions.set, size: {
      timetableColumn: size,
      todoColumn: getSize![todoColumn]!,
      noteColumn: getSize[noteColumn]!,
    });
  }

  Future<void> deleteUserDocumentary({required String doc}) async {
    try {
      final ref = _storage.ref('${_user!.uid}/$doc/');
      final result = await ref.listAll();
      for (final childRef in result.items) {
        await childRef.delete();
      }
    } catch (e) {
      //todo
    }
  }

  Future<void> uploadNotes({
    required List<Note> notes,
    required CallbackAction? callback,
  }) async {
    bool isProgress = callback != null;
    int len = notes.length;
    double progress = 0.0;
    final collection = _firestore.collection('users/${_user!.uid}/notes');
    final backUpSizeCollection =
        _firestore.collection('users/${_user!.uid}/backupSize');

    await deleteBackUp(collectionTable: "notes");
    await deleteUserDocumentary(doc: "files");
    await deleteUserDocumentary(doc: "images");

    for (int i = 0; i < len; i++) {
      final List<String> netFiles = [];
      final List<String> netImages = [];
      if (isProgress) {
        progress = (i + 1) / len * 100;
        callback("Progress: ${progress.toStringAsFixed(2)}%");
      }
      final note = notes[i];
      for (final image in note.images) {
        final uploaded = await uploadFile(filePath: image, type: "images");
        if (uploaded != null) {
          netImages.add(uploaded);
        }
      }
      for (final file in note.files) {
        final uploaded = await uploadFile(filePath: file, type: "files");
        if (uploaded != null) {
          netFiles.add(uploaded);
        }
      }
      await collection.add(
        note
            .copyWith(
              files: netFiles,
              images: netImages,
            )
            .toMap(),
      );
    }
    String size = convertSizeUnit(size: calculateNoteSize(notes: notes));
    await backUpSizeCollection.doc(_user!.uid).set(
      {noteColumn: size},
      SetOptions(merge: true),
    );
    final getSize = await spRestoreSize(action: SPActions.get);
    spRestoreSize(action: SPActions.set, size: {
      noteColumn: size,
      todoColumn: getSize![todoColumn]!,
      timetableColumn: getSize[timetableColumn]!,
    });
  }

  Future<List<Note>> getAllNotes() async {
    try {
      final querySnapshot = await _firestore
          .collection("users")
          .doc(_user!.uid)
          .collection("notes")
          .get();

      final allNotes =
          querySnapshot.docs.map((doc) => Note.fromMap(doc.data())).toList();
      return allNotes;
    } catch (e) {
      return [];
    }
  }

  Future<void> deleteBackUp({required String collectionTable}) async {
    final collection = _firestore.collection(
      'users/${_user!.uid}/$collectionTable',
    );
    await collection.get().then(
      (snapshot) {
        for (final doc in snapshot.docs) {
          doc.reference.delete();
        }
      },
    );
  }

  Future<List<TimeTable>> getAllTimeTables() async {
    try {
      final querySnapshot = await _firestore
          .collection("users")
          .doc(_user!.uid)
          .collection("timetables")
          .get();

      final allTimeTables = querySnapshot.docs
          .map((doc) => TimeTable.fromMap(doc.data()))
          .toList();
      return allTimeTables;
    } catch (e) {
      return [];
    }
  }

  Future<String> copyFile({required String filepath}) async {
    final file = File(filepath);
    final appDir = await getApplicationDocumentsDirectory();
    final copyPath = '${appDir.path}/${basename(file.path)}';
    List<int>? compressedImageData = await compressImage(
      filePath: file.path,
      quality: 50,
    );
    if (compressedImageData != null) {
      await File(copyPath).writeAsBytes(compressedImageData);
    }
    return copyPath;
  }

  Future<void> updateProfilePic({required String profilePicPath}) async {
    final profileData = await _uploadProfilePicture(
      userId: _user!.uid,
      profilePicPath: profilePicPath,
    );
    _user = _user!.copyWith(
      profilePic: profileData[userProfilePic],
      profilePicURL: profileData[userProfilePicURL],
    );
    await FirebaseAuth.instance.currentUser!.updatePhotoURL(
      profileData[userProfilePicURL],
    );
    _userController.add(_user);
    await spUserActions(
      action: SPActions.set,
      userJson: jsonEncode(_user!.toMap()),
    );
  }

  Future<String?> uploadFile({
    required String filePath,
    required String type,
  }) async {
    final String fileName = filePath.split('_').last;
    final String storagePath = '${_user!.uid}/$type/$fileName';
    try {
      final file = File(filePath);
      if (file.existsSync()) {
        final storageRef = _storage.ref(storagePath);
        await storageRef.putFile(file);
        return storageRef.getDownloadURL();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, String>> _uploadProfilePicture({
    required String userId,
    required String profilePicPath,
  }) async {
    final file = File(profilePicPath);
    final fileName = '${const Uuid().v4()}_${basename(file.path)}';

    final copyPath = await copyFile(filepath: profilePicPath);
    deleteUserDocumentary(doc: "profile_pictures");
    final storageRef =
        _storage.ref().child('$userId/profile_pictures').child(fileName);
    final uploadTask = storageRef.putFile(file);
    await uploadTask.whenComplete(() => null);

    final profilePicUrl = await storageRef.getDownloadURL();
    return {
      userProfilePicURL: profilePicUrl,
      userProfilePic: copyPath,
    };
  }

  Future<AuthError?> logOut() async {
    try {
      await GoogleSignIn().signOut();
      await _auth.signOut();
      await _deleteProfilePicture();
      await NotificationService.cancelALLScheduleNotification();
      await spUserActions(action: SPActions.delete);
      await spRestoreSize(action: SPActions.delete);
      _user = null;
      _userController.add(_user);
      return null;
    } on FirebaseAuthException catch (e) {
      return AuthError.from(e);
    }
  }

  void setUser(User user, String? profilePath) async {
    _user = FBUser(
      uid: user.uid,
      fullname: user.displayName!,
      username: user.displayName!.toLowerCase().split(' ').join(),
      email: user.email!,
      verified: user.emailVerified,
      profilePic: profilePath,
      profilePicURL: user.photoURL,
    );
    final userJson = jsonEncode(_user!.toMap());
    await spUserActions(action: SPActions.set, userJson: userJson);
    _userController.add(_user);
  }

  Future<void> _deleteProfilePicture() async {
    final file = File('${_user?.profilePic}');
    if (file.existsSync()) {
      file.deleteSync();
    }
  }

  void userStr() async {
    if (_user != null) {
      _userController.add(_user);
      return;
    }
    final userJson = await spUserActions(action: SPActions.get);
    if (userJson == null) {
      _userController.add(null);
      return;
    }
    final userMapData = jsonDecode(userJson);
    _user = FBUser.fromMap(userMapData);
    _userController.add(_user);
  }

  Future<String?> spUserActions({
    required SPActions action,
    String? userJson,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    switch (action) {
      case SPActions.set:
        await prefs.setString(loggedUser, userJson!);
        return null;
      case SPActions.get:
        return prefs.getString(loggedUser);
      case SPActions.delete:
        await prefs.remove(loggedUser);
        return null;
    }
  }

  Future<Map<String, String>?> spRestoreSize({
    required SPActions action,
    Map<String, String>? size,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    switch (action) {
      case SPActions.set:
        await prefs.setString(restoreSize, jsonEncode(size));
        _restore = size;
        return null;
      case SPActions.get:
        final jsonString = prefs.getString(restoreSize);
        if (jsonString != null) {
          final data = jsonDecode(jsonString);
          return {
            timetableColumn: data[timetableColumn],
            todoColumn: data[todoColumn],
            noteColumn: data[noteColumn],
          };
        }
        return null;
      case SPActions.delete:
        await prefs.remove(restoreSize);
        return null;
    }
  }

  Future<void> downloadProfileImage() async {
    try {
      final response = await http.get(Uri.parse(_user!.profilePicURL!));
      if (response.statusCode == 200) {
        final appDir = await getApplicationDocumentsDirectory();
        final file = File('${appDir.path}/profile_${const Uuid().v4()}.jpg');
        await _deleteProfilePicture();
        await file.writeAsBytes(response.bodyBytes);
        _user = _user!.copyWith(profilePic: file.path);
        await spUserActions(
            action: SPActions.set, userJson: jsonEncode(_user!.toMap()));
        _userController.add(_user);
      }
    } catch (e) {
      //todo
    }
  }

  Future<String?> downloadFile({required String fileURL}) async {
    try {
      final fileName = getFileName(url: fileURL);
      final response = await http.get(Uri.parse(fileURL));
      if (response.statusCode == 200) {
        final appDir = await getApplicationDocumentsDirectory();
        final file = File('${appDir.path}/downloaded/_$fileName');
        await file.create(recursive: true);
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

const List<String> units = ['bytes', 'KB', 'MB', 'GB', 'TB'];
typedef CallbackAction<T> = void Function(T);

double calculateSize({
  required List<dynamic> list,
  CallbackAction? callback,
}) {
  double size = 0;

  for (final item in list) {
    final jsonString = jsonEncode(item.toMap());
    int bytes = utf8.encode(jsonString).length;
    size += bytes;
  }
  if (callback != null) {
    callback(size.toDouble());
  }
  return size.toDouble();
}

double calculateNoteSize({
  required List<Note> notes,
  CallbackAction? callback,
}) {
  double size = 0;
  for (final item in notes) {
    final jsonString = jsonEncode(item.toMap());
    int bytes = utf8.encode(jsonString).length;
    size += bytes;
  }

  for (final note in notes) {
    for (final image in note.images) {
      final file = File(image);
      if (file.existsSync()) {
        size += file.lengthSync();
      }
    }
    for (final docs in note.files) {
      final file = File(docs);
      if (file.existsSync()) {
        size += file.lengthSync();
      }
    }
  }
  if (callback != null) {
    callback(size.toDouble());
  }
  return size.toDouble();
}

String convertSizeUnit({
  required double size,
}) {
  int unitIndex = 0;
  double convertedSize = size;
  while (convertedSize >= 1024 && unitIndex < units.length - 1) {
    convertedSize /= 1024;
    unitIndex++;
  }
  return '${convertedSize.toStringAsFixed(1)} ${units[unitIndex]}';
}

String getFileName({required String url}) {
  final uri = Uri.parse(url);
  final filePath = uri.path;
  final decodedFilePath = Uri.decodeComponent(filePath);
  return basename(decodedFilePath);
}
