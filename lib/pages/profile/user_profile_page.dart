import 'package:flutter/material.dart';
import 'package:my_timetable/pages/profile/tabs_screen.dart';
import 'package:my_timetable/widgets/animate_route.dart' show FadeRoute;

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          height: double.infinity,
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(26, 90, 26, 20),
          child: Column(
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
                  const Text(
                    "Fullname",
                    style: TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 6.0,
                  ),
                  const Text(
                    "@username",
                    style: TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      ElevatedButton(
                        style: ButtonStyle(
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry>(
                            const EdgeInsets.symmetric(
                              vertical: 12.0,
                              horizontal: 24.0,
                            ),
                          ),
                          backgroundColor: MaterialStateColor.resolveWith(
                            (states) => Colors.black.withAlpha(60),
                          ),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).push(
                          FadeRoute(
                            page: const TabsScreen(),
                          ),
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(
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
              Column(
                children: <Widget>[
                  myTile(title: "Backup", icon: Icons.backup, index: 0),
                  const SizedBox(
                    height: 10.0,
                  ),
                  myTile(title: "Restore", icon: Icons.restore, index: 1),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  ListTile myTile({
    required String title,
    required IconData icon,
    required int index,
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
      minVerticalPadding: 20.0,
      title: Text(title),
    );
  }
}
