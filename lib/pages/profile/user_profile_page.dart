import 'dart:io' show File;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:neverlost/pages/profile/backup_register/backup_screen.dart';
import 'package:neverlost/pages/profile/backup_register/restore_screen.dart';
import 'package:neverlost/pages/profile/tabs_screen/tabs_screen.dart';
import 'package:neverlost/services/database.dart';
import 'package:neverlost/services/firebase_auth_services/firebase_service.dart';
import 'package:neverlost/services/timetable_services/timetable.dart';
import 'package:neverlost/utils.dart';
import 'package:neverlost/widgets/animate_route.dart' show FadeRoute;
import 'package:neverlost/widgets/dialog_boxs.dart';
import 'package:neverlost/widgets/loading/loading_screen.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

enum ProfileActions {
  backup,
  restore,
}

class _UserProfileState extends State<UserProfile> {
  final DatabaseService _db = DatabaseService();
  final FirebaseService _firebase = FirebaseService.instance();
  late final List<TimeTable> _timetables;
  String? _backUpSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _firebase.userStr();
      _timetables = _db.cachedTimeTables;
    });
  }

  void notConnectedToInternet() {
    errorDialogue(
      context: context,
      title: "No Internet Connection",
      message: "You are not connected to internet",
    );
  }

  Future<void> logOutUser() async {
    if (await confirmDialogue(
      context: context,
      message: "Do you really want to logout?",
      title: "Logout",
    )) {
      if (!await checkConnection()) {
        return;
      }
      final success = await FirebaseService.instance().logOut();
      if (success != null) {
        Future.delayed(
          const Duration(milliseconds: 100),
          () => errorDialogue(
            context: context,
            message: success.dialogText,
            title: success.dialogTitle,
          ),
        );
      }
    }
  }

  Future<bool> makeBackUp() async {
    if (_timetables.isEmpty) {
      errorDialogue(
        context: context,
        title: "No TimeTable Found",
        message: "There is no timetable found to be saved in backup",
      );
      return false;
    }
    if (!await checkConnection()) {
      return false;
    }
    showLoading(message: "Backup is in progress..");
    await _firebase.uploadTimetables(
      timetables: _timetables,
    );
    LoadingScreen.instance().hide();
    showSnak(message: "Backup saved successfully!");
    setState(() {});
    return true;
  }

  Future<bool> restoreBackup() async {
    if (_backUpSize == null) {
      errorDialogue(
        context: context,
        title: "No Backup Found",
        message: "Ensure that you have made a backup, click on backup!",
      );
      return false;
    }
    if (!await checkConnection()) {
      return false;
    }
    showLoading(message: "Restoring data...");
    final List<TimeTable> allTimeTables = await _firebase.getAllTimeTables();
    await _db.cleanTimeTable();
    for (int i = 0; i < allTimeTables.length; i++) {
      final timetable = allTimeTables[i];
      await _db.insertTimeTable(
        subject: timetable.subject,
        professor: timetable.professor,
        daytimes: timetable.dayTime,
      );
    }
    LoadingScreen.instance().hide();
    showSnak(message: "Restoration completed!");
    return true;
  }

  Future<bool> checkConnection() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      notConnectedToInternet();
      return false;
    }
    return true;
  }

  void performProfileActions(ProfileActions action) async {
    switch (action) {
      case ProfileActions.backup:
        if (await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const BackupScreen(),
            )) ??
            false) {
          await makeBackUp();
        }
        break;
      case ProfileActions.restore:
        if (await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const RestoreScreen(),
            )) ??
            false) {
          await restoreBackup();
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          height: double.infinity,
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(26, 90, 26, 20),
          child: StreamBuilder(
            stream: _firebase.userStream,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                case ConnectionState.done:
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  );
                case ConnectionState.active:
                  dynamic userData = snapshot.data;
                  bool profilePic = userData?.profilePic != null;
                  if (!profilePic) {
                    _firebase.downloadProfileImage();
                  }
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          profileImage(profilePic, userData),
                          const SizedBox(
                            height: 16.0,
                          ),
                          Text(
                            userData != null ? userData.fullname : "Fullname",
                            style: const TextStyle(
                              fontSize: 26.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 6.0,
                          ),
                          Text(
                            "@${userData != null ? userData.username : 'username'}",
                            style: const TextStyle(fontSize: 16.0),
                          ),
                          const SizedBox(
                            height: 16.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              ElevatedButton(
                                style: ButtonStyle(
                                  padding: MaterialStateProperty.all<
                                      EdgeInsetsGeometry>(
                                    const EdgeInsets.symmetric(
                                      vertical: 12.0,
                                      horizontal: 24.0,
                                    ),
                                  ),
                                  backgroundColor:
                                      MaterialStateColor.resolveWith(
                                    (states) => Colors.black.withAlpha(60),
                                  ),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                  ),
                                ),
                                onPressed: userData == null
                                    ? () => Navigator.of(context).push(
                                          FadeRoute(
                                            page: const TabsScreen(),
                                          ),
                                        )
                                    : () async => logOutUser(),
                                child: Text(
                                  userData != null ? "Logout" : "Login",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (userData != null) backUpAndRestore()
                    ],
                  );
              }
            },
          ),
        ),
      ),
    );
  }

  Stack profileImage(bool profilePic, userData) {
    return Stack(
      children: <Widget>[
        CircleAvatar(
          backgroundColor: Colors.black.withAlpha(120),
          radius: 70.0,
          backgroundImage:
              profilePic ? FileImage(File(userData.profilePic)) : null,
          child: !profilePic
              ? const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 100.0,
                )
              : null,
        ),
        Positioned(
          bottom: -6,
          right: -4,
          child: Center(
            child: IconButton(
              onPressed: () => _pickImage(),
              icon: const Icon(
                Icons.camera,
                color: Colors.white,
              ),
              iconSize: 40.0,
            ),
          ),
        ),
      ],
    );
  }

  void showLoading({required String message}) => LoadingScreen.instance().show(
        context: context,
        text: message,
      );

  void showSnak({required String message}) => showSnackBar(context, message);

  void _pickImage() async {
    final pickedFile = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.image,
    );

    if (pickedFile != null) {
      showLoading(message: "Saving....");
      await _firebase.updateProfilePic(
        profilePicPath: pickedFile.files.first.path!,
      );
      LoadingScreen.instance().hide();
    }
  }

  Column backUpAndRestore() {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    );
    return Column(
      children: <Widget>[
        ListTile(
          shape: shape,
          leading: const Icon(
            Icons.backup,
          ),
          key: const ValueKey(0),
          tileColor: Colors.black.withAlpha(90),
          title: const Text("Backup"),
          subtitle: Text(_firebase.calculateSize(_timetables)),
          onTap: () => performProfileActions(
            ProfileActions.backup,
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        ListTile(
          shape: shape,
          leading: const Icon(
            Icons.restore,
          ),
          key: const ValueKey(1),
          tileColor: Colors.black.withAlpha(90),
          title: const Text("Restore"),
          subtitle: FutureBuilder(
            future: _firebase.restoreDataSize(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  _backUpSize = snapshot.data;
                  return Text(_backUpSize ?? "0 bytes");
                default:
                  return const Text("Loading...");
              }
            },
          ),
          onTap: () => performProfileActions(
            ProfileActions.restore,
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}
