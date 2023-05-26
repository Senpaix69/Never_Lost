import 'dart:convert' show jsonEncode, utf8;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:neverlost/pages/profile/tabs_screen.dart';
import 'package:neverlost/services/database.dart';
import 'package:neverlost/services/firebase_auth_services/firebase_service.dart';
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
  late final List<dynamic> _timetables;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirebaseService.instance().userStr();
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
    // todo make backup for all the timetables
    return false;
  }

  Future<bool> restoreBackup() async {
    // todo make restorebackup for all the timetables
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

  String calculateSize(List<dynamic> list) {
    const List<String> units = ['bytes', 'KB', 'MB', 'GB', 'TB'];
    double size = 0;
    int unitIndex = 0;
    for (int i = 0; i < list.length; i++) {
      final timetable = list[i].toMap();
      final jsonString = jsonEncode(timetable);
      int bytes = utf8.encode(jsonString).length;
      size += bytes;

      if (size >= 1024 && unitIndex < units.length - 1) {
        size /= 1024;
        unitIndex++;
      }
    }
    return '${size.roundToDouble().toStringAsFixed(0)} ${units[unitIndex]}';
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
            stream: FirebaseService.instance().userStream,
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
                            userData != null
                                ? userData['fullname']
                                : "Fullname",
                            style: const TextStyle(
                              fontSize: 26.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 6.0,
                          ),
                          Text(
                            "@${userData != null ? userData['username'] : 'username'}",
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
                      if (userData != null)
                        Column(
                          children: <Widget>[
                            myTile(
                              title: "Backup",
                              icon: Icons.backup,
                              index: 0,
                              size: calculateSize(_timetables),
                              callback: () => performProfileActions(
                                ProfileActions.backup,
                              ),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            myTile(
                              title: "Restore",
                              icon: Icons.restore,
                              size: '0 bytes',
                              index: 1,
                              callback: () => performProfileActions(
                                ProfileActions.restore,
                              ),
                            ),
                          ],
                        )
                    ],
                  );
              }
            },
          ),
        ),
      ),
    );
  }

  ListTile myTile({
    required String title,
    required IconData icon,
    required String size,
    required int index,
    required VoidCallback callback,
  }) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      leading: Icon(
        icon,
      ),
      key: ValueKey(index),
      tileColor: Colors.black.withAlpha(90),
      title: Text(title),
      subtitle: Text(size),
      onTap: callback,
    );
  }
}
