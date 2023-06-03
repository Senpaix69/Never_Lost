import 'dart:async' show StreamController;
import 'dart:convert' show jsonDecode, jsonEncode, utf8;
import 'dart:io' show File, HttpClient, HttpStatus;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart'
    show consolidateHttpClientResponseBytes;
import 'package:neverlost/contants/firebase_contants/firebase_contants.dart';
import 'package:neverlost/services/firebase_auth_services/fb_user.dart';
import 'package:neverlost/services/note_services/todo.dart';
import 'package:neverlost/services/notification_service.dart';
import 'package:neverlost/services/timetable_services/timetable.dart';
import 'package:path/path.dart' show basename;
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
  FBUser? _user;

  FBUser? get user => _user;

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
  // Login
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
      // Upload profile picture to Firebase Storage
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

  Future<void> uploadTodos({required List<Todo> todos}) async {
    final collection = _firestore.collection(
      'users/${_user!.uid}/todos',
    );
    await deleteBackUp(collectionTable: "todos");
    for (final todo in todos) {
      await collection.add(todo.toMap());
    }
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
  }) async {
    final collection = _firestore.collection(
      'users/${_user!.uid}/timetables',
    );
    await deleteBackUp(collectionTable: "timetables");

    for (final timetable in timetables) {
      final sub = timetable.subject.copyWith(sched: 0);
      await collection.add(
        timetable.copyWith(subject: sub).toMap(),
      );
    }
    String size = calculateSize(timetables);
    await spRestoreSize(action: SPActions.set, size: size);
    final backUpSizeCollection = _firestore.collection(
      'users/${_user!.uid}/backupSize',
    );

    await backUpSizeCollection.get().then((snapshot) {
      for (final doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    await backUpSizeCollection.add({
      'size': size,
    });
  }

  Future<void> deleteBackUp({required String collectionTable}) async {
    final collection = _firestore.collection(
      'users/${_user!.uid}/$collectionTable',
    );
    await collection.get().then((snapshot) {
      for (final doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
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
    // copy the image
    final file = File(filepath);
    final appDir = await getApplicationDocumentsDirectory();
    final copyPath = '${appDir.path}/${basename(file.path)}';
    await File(filepath).copy(copyPath);
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

  Future<Map<String, String>> _uploadProfilePicture({
    required String userId,
    required String profilePicPath,
  }) async {
    final file = File(profilePicPath);
    final fileName = '${const Uuid().v4()}_${basename(file.path)}';

    final copyPath = await copyFile(filepath: profilePicPath);

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('$userId/profile_pictures')
        .child(fileName);
    final uploadTask = storageRef.putFile(file);
    await uploadTask.whenComplete(() => null);

    final profilePicUrl = await storageRef.getDownloadURL();
    return {
      userProfilePicURL: profilePicUrl,
      userProfilePic: copyPath,
    };
  }

  String calculateSize(List<dynamic> list) {
    const List<String> units = ['bytes', 'KB', 'MB', 'GB', 'TB'];
    double size = 0;
    int unitIndex = 0;
    for (int i = 0; i < list.length; i++) {
      final item = list[i].toMap();
      final jsonString = jsonEncode(item);
      int bytes = utf8.encode(jsonString).length;
      size += bytes;
    }
    double convertedSize = size.toDouble();
    while (convertedSize >= 1024 && unitIndex < units.length - 1) {
      convertedSize /= 1024;
      unitIndex++;
    }
    return '${convertedSize.toStringAsFixed(1)} ${units[unitIndex]}';
  }

  Future<String?> restoreDataSize() async {
    String? size = await spRestoreSize(action: SPActions.get);
    if (size == null) {
      final backUpSize = await _firestore
          .collection(
            'users/${_user!.uid}/backupSize',
          )
          .get()
          .then((snap) => snap.docs.first);
      if (backUpSize.exists) {
        await spRestoreSize(action: SPActions.set, size: backUpSize['size']);
        return backUpSize['size'];
      }
      return null;
    }
    return size;
  }

  Future<AuthError?> logOut() async {
    try {
      await GoogleSignIn().signOut();
      await _auth.signOut();
      await NotificationService.cancelALLScheduleNotification();
      _user = null;
      await spUserActions(action: SPActions.delete);
      await spRestoreSize(action: SPActions.delete);
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

  Future<String?> spRestoreSize({
    required SPActions action,
    String? size,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    switch (action) {
      case SPActions.set:
        await prefs.setString(restoreSize, size!);
        return null;
      case SPActions.get:
        return prefs.getString(restoreSize);
      case SPActions.delete:
        await prefs.remove(restoreSize);
        return null;
    }
  }

  Future<void> downloadProfileImage() async {
    try {
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(
        Uri.parse(_user!.profilePicURL!),
      );
      final response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        final appDir = await getApplicationDocumentsDirectory();
        final bytes = await consolidateHttpClientResponseBytes(response);
        final file = File('${appDir.path}/profile_image.jpg');
        await file.writeAsBytes(bytes);
        _user = _user!.copyWith(profilePic: file.path);
        _userController.add(_user);
        await spUserActions(
            action: SPActions.set, userJson: jsonEncode(_user!.toMap()));
      }
    } catch (e) {
      //todo
    }
  }
}
