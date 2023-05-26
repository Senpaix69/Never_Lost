import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:neverlost/pages/profile/tabs_screen.dart';
import 'package:neverlost/services/database.dart';
import 'package:neverlost/services/firebase_auth_services/firebase_service.dart';
import 'package:neverlost/services/timetable_services/timetable.dart';
import 'package:neverlost/widgets/animate_route.dart' show FadeRoute;
import 'package:neverlost/widgets/dialog_boxs.dart';

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
  bool _backUpLoading = false;
  bool _restoreLoading = false;

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
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        notConnectedToInternet();
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
    setState(() => _backUpLoading = true);
    await _firebase.uploadTimetables(
      timetables: _timetables,
    );
    setState(() => _backUpLoading = false);
    return false;
  }

  Future<bool> restoreBackup() async {
    setState(() => _restoreLoading = true);
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
    setState(() => _restoreLoading = false);
    return false;
  }

  void performProfileActions(ProfileActions action) async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      notConnectedToInternet();
      return;
    }
    switch (action) {
      case ProfileActions.backup:
        await makeBackUp();
        break;
      case ProfileActions.restore:
        await restoreBackup();
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
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          CircleAvatar(
                            backgroundColor: Colors.black.withAlpha(120),
                            radius: 80.0,
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 100.0,
                            ),
                          ),
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
          trailing: _backUpLoading
              ? const CircularProgressIndicator()
              : const Icon(
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
              if (snapshot.hasData) {
                return Text('${snapshot.data}');
              } else {
                return const Text("Loading...");
              }
            },
          ),
          onTap: () => performProfileActions(
            ProfileActions.restore,
          ),
          trailing: _restoreLoading
              ? const CircularProgressIndicator()
              : const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}
