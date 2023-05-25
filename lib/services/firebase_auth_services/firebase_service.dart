import 'dart:async' show StreamController;
import 'dart:convert' show jsonEncode, jsonDecode;
import 'dart:io' show File;
import 'package:path/path.dart' show basename;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neverlost/services/firebase_auth_services/auth_errors.dart';
import 'package:uuid/uuid.dart';

const loggedUser = 'loggedInUser';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

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
  }) async {
    await logOut();

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = userCredential.user;
      setUser(_user!, null);
      return null;
    } on FirebaseAuthException catch (e) {
      return AuthError.from(e);
    }
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

      // Upload profile picture to Firebase Storage
      if (profilePicPath != null) {
        final profilePicUrl = await _uploadProfilePicture(
          userId: userId,
          profilePicPath: profilePicPath,
        );
        await userCredential.user!.updatePhotoURL(profilePicUrl);
      }
      await userCredential.user!.updateDisplayName(fullName);
      await FirebaseAuth.instance.signOut();
      return loginWithEmailPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      return AuthError.from(e);
    }
  }

  Future<String> _uploadProfilePicture({
    required String userId,
    required String profilePicPath,
  }) async {
    final file = File(profilePicPath);
    final fileName = '${const Uuid().v4()}_${basename(file.path)}';

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('profile_pictures')
        .child(fileName);
    final uploadTask = storageRef.putFile(file);

    await uploadTask.whenComplete(() => null);

    final profilePicUrl = await storageRef.getDownloadURL();
    return profilePicUrl;
  }

  // Logout
  Future<AuthError?> logOut() async {
    try {
      await _auth.signOut();
      _user = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(loggedUser);
      _userController.add(_user);
      return null;
    } on FirebaseAuthException catch (e) {
      return AuthError.from(e);
    }
  }

  void setUser(User user, String? profilePath) async {
    final userData = {
      'email': user.email!,
      'fullname': user.displayName!,
      'username': user.displayName!.toLowerCase().split(' ').join(),
      'profilePic': profilePath,
    };
    final userJson = jsonEncode(userData);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(loggedUser, userJson);
    _userController.add(userData);
  }

  void userStr() async {
    if (_user != null) {
      _userController.add({
        'email': _user!.email!,
        'fullname': _user!.displayName,
        'username': _user!.displayName!.toLowerCase().split(' ').join(),
      });
    }
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(loggedUser);
    _userController.add(userJson != null ? jsonDecode(userJson) : null);
  }
}
