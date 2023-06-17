import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:neverlost/services/firebase_auth_services/fb_user.dart';
import 'package:neverlost/services/firebase_auth_services/firebase_service.dart';
import 'package:neverlost/utils.dart' show checkConnection;
import 'package:neverlost/widgets/dialog_boxs.dart';
import 'package:neverlost/widgets/loading/loading_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final FirebaseService _firebase = FirebaseService.instance();
  @override
  void initState() {
    super.initState();
    _firebase.userStr();
  }

  void notConnectedToInternet() {
    LoadingScreen.instance().hide();
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
      showLoading(
        title: "Connectivity Check",
        message: "Checking connection...",
      );
      if (!await checkConnection()) {
        notConnectedToInternet();
        return;
      }
      showLoading(title: "User", message: "Logging user out...");
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
      LoadingScreen.instance().hide();
    }
  }

  void showLoading({required String message, required String title}) =>
      LoadingScreen.instance().show(
        context: context,
        text: message,
        title: title,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 100.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ProfileWidget(firebase: _firebase, logOutUser: logOutUser),
            Column(
              children: <Widget>[
                ListTile(
                  onTap: () {},
                  leading: const Icon(Icons.color_lens_rounded),
                  title: const Text("Themes"),
                ),
                ListTile(
                  onTap: () {},
                  leading: const Icon(Icons.backup),
                  title: const Text("Backup"),
                ),
                ListTile(
                  onTap: () {},
                  leading: const Icon(Icons.restore),
                  title: const Text("Restore"),
                ),
                ListTile(
                  onTap: () {},
                  leading: const Icon(Icons.adb_outlined),
                  title: const Text("About"),
                ),
              ],
            ),
            const Spacer(),
            LogoutButton(
              firebase: _firebase,
              logOutUser: logOutUser,
            ),
          ],
        ),
      ),
    );
  }
}

class LogoutButton extends StatelessWidget {
  const LogoutButton({
    super.key,
    required FirebaseService firebase,
    required VoidCallback logOutUser,
  })  : _firebase = firebase,
        _logOutUser = logOutUser;

  final FirebaseService _firebase;
  final VoidCallback _logOutUser;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firebase.userStream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
          case ConnectionState.done:
            return const SizedBox();
          case ConnectionState.active:
            final user = snapshot.data as FBUser?;
            if (user != null) {
              return TextButton.icon(
                onPressed: _logOutUser,
                style: ButtonStyle(
                    shape: MaterialStateProperty.resolveWith(
                      (states) => RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    backgroundColor: MaterialStateColor.resolveWith(
                      (states) => Theme.of(context).primaryColorDark,
                    )),
                icon: Icon(
                  Icons.logout,
                  color: Theme.of(context).secondaryHeaderColor,
                ),
                label: Text(
                  "Logout",
                  style: TextStyle(
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
                ),
              );
            }
            return const SizedBox();
        }
      },
    );
  }
}

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({
    super.key,
    required FirebaseService firebase,
    required VoidCallback logOutUser,
  })  : _firebase = firebase,
        _logOutUser = logOutUser;

  final FirebaseService _firebase;
  final VoidCallback _logOutUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20.0),
      child: StreamBuilder(
        stream: _firebase.userStream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.done:
              return defaultUser(context);
            case ConnectionState.active:
              final user = snapshot.data as FBUser?;
              bool isProfile = user?.profilePic != null;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      radius: 40.0,
                      backgroundColor: Theme.of(context).focusColor,
                      backgroundImage: isProfile
                          ? FileImage(
                              File(
                                user!.profilePic!,
                              ),
                            )
                          : null,
                      child: !isProfile
                          ? const Icon(
                              Icons.person_2,
                              size: 40.0,
                            )
                          : null,
                    ),
                  ),
                  if (user == null)
                    TextButton.icon(
                      onPressed: _logOutUser,
                      style: ButtonStyle(
                          shape: MaterialStateProperty.resolveWith(
                            (states) => RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          backgroundColor: MaterialStateColor.resolveWith(
                            (states) => Theme.of(context).primaryColorDark,
                          )),
                      icon: Icon(
                        Icons.logout,
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                      label: Text(
                        "Login",
                        style: TextStyle(
                          color: Theme.of(context).secondaryHeaderColor,
                        ),
                      ),
                    ),
                  if (user != null)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      onTap: () {},
                      title: Text(
                        user.fullname,
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                ],
              );
          }
        },
      ),
    );
  }
}

CircleAvatar defaultUser(BuildContext context) {
  return CircleAvatar(
    backgroundColor: Theme.of(context).focusColor,
    child: Icon(
      Icons.person_2,
      color: Theme.of(context).secondaryHeaderColor,
    ),
  );
}
