import 'dart:io' show File;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:neverlost/pages/profile/setting_screens/settings_screen.dart';
import 'package:neverlost/pages/profile/tabs_screen/tabs_screen.dart';
import 'package:neverlost/services/firebase_auth_services/firebase_service.dart';
import 'package:neverlost/utils.dart' show checkConnection;
import 'package:neverlost/widgets/animate_route.dart' show FadeRoute;
import 'package:neverlost/widgets/dialog_boxs.dart';
import 'package:neverlost/widgets/loading/loading_screen.dart';
import 'package:neverlost/widgets/my_custom_tile.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final FirebaseService _firebase = FirebaseService.instance();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _firebase.userStr();
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: double.infinity,
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(26, 60, 26, 20),
          child: StreamBuilder(
            stream: _firebase.userStream,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                case ConnectionState.done:
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.grey,
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
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Theme.of(context)
                                  .primaryColorDark
                                  .withOpacity(.3),
                              spreadRadius: 6,
                              blurRadius: 20.0,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Column(
                          children: <Widget>[
                            profileImage(profilePic, userData),
                            const SizedBox(
                              height: 16.0,
                            ),
                            Text(
                              userData != null ? userData.fullname : "Fullname",
                              style: const TextStyle(
                                fontSize: 26.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 6.0,
                            ),
                            Text(
                              "@${userData != null ? userData.username : 'username'}",
                              style: const TextStyle(
                                fontSize: 16.0,
                                color: Colors.white,
                              ),
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
                                      (states) => Theme.of(context).focusColor,
                                    ),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
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
                      ),
                      if (userData != null) profileOptions(),
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
        if (userData != null)
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

  Column profileOptions() {
    return Column(
      children: <Widget>[
        MyCustomTile(
          iconBackGroundColor: Colors.grey.shade600,
          icon: Icons.settings,
          onClick: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ProfileSettings()),
          ),
          title: "Settings",
        ),
        const SizedBox(
          height: 10.0,
        ),
      ],
    );
  }
}
