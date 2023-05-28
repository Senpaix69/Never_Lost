import 'package:flutter/material.dart';
import 'package:neverlost/pages/profile/profile_screens/backup_screen.dart';
import 'package:neverlost/pages/profile/profile_screens/restore_screen.dart';
import 'package:neverlost/services/database.dart';
import 'package:neverlost/services/firebase_auth_services/firebase_service.dart';
import 'package:neverlost/services/note_services/todo.dart';
import 'package:neverlost/services/notification_service.dart';
import 'package:neverlost/services/timetable_services/timetable.dart';
import 'package:neverlost/utils.dart' show checkConnection, showSnackBar;
import 'package:neverlost/widgets/dialog_boxs.dart' show errorDialogue;
import 'package:neverlost/widgets/loading/loading_screen.dart';
import 'package:neverlost/widgets/my_custom_tile.dart';

enum ProfileActions {
  backup,
  restore,
}

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  final DatabaseService _db = DatabaseService();
  final FirebaseService _firebase = FirebaseService.instance();
  late final List<TimeTable> _timetables;
  late final List<Todo> _todos;
  String? _restoreSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _timetables = _db.cachedTimeTables;
      _todos = _db.cachedTodos;
      _restoreSize = await _firebase.restoreDataSize();
    });
  }

  void notConnectedToInternet() {
    errorDialogue(
      context: context,
      title: "No Internet Connection",
      message: "You are not connected to internet",
    );
  }

  Future<bool> makeBackUp() async {
    if (_timetables.isEmpty || _todos.isEmpty) {
      errorDialogue(
        context: context,
        title: "No TimeTable Found",
        message: "There is no timetable found to be saved in backup",
      );
      return false;
    }
    if (!await checkConnection()) {
      notConnectedToInternet();
      return false;
    }
    showLoading(message: "Backup is in progress...");
    await _firebase.uploadTimetables(
      timetables: _timetables,
    );
    await _firebase.uploadTodos(todos: _todos);
    LoadingScreen.instance().hide();
    showSnak(message: "Backup saved successfully!");
    setState(() {});
    return true;
  }

  void showLoading({required String message}) => LoadingScreen.instance().show(
        context: context,
        text: message,
      );

  void showSnak({required String message}) => showSnackBar(context, message);

  Future<bool> restoreBackup() async {
    if (_restoreSize == null) {
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
    final List<Todo> allTodos = await _firebase.getAllTodos();
    await _db.cleanTimeTable();
    await _db.cleanTotoTable();
    await NotificationService.cancelALLScheduleNotification();
    for (int i = 0; i < allTimeTables.length; i++) {
      final timetable = allTimeTables[i];
      await _db.insertTimeTable(
        subject: timetable.subject,
        professor: timetable.professor,
        daytimes: timetable.dayTime,
      );
    }
    for (int i = 0; i < allTodos.length; i++) {
      final todo = allTodos[i];
      await _db.insertTodo(todo: todo);
    }
    LoadingScreen.instance().hide();
    showSnak(message: "Restoration completed!");
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        padding: const EdgeInsets.only(
          top: 50,
          bottom: 30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_outlined),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Text(
                    "Settings",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            MyCustomTile(
              icon: Icons.app_shortcut_rounded,
              onClick: () {},
              iconBackGroundColor: Colors.lightBlue,
              title: "About App",
            ),
            MyCustomTile(
              icon: Icons.person_2,
              onClick: () {},
              iconBackGroundColor: Colors.orangeAccent,
              title: "About Developer",
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                height: 40,
                color: Colors.grey[900],
              ),
            ),
            MyCustomTile(
              icon: Icons.color_lens,
              onClick: () {},
              iconBackGroundColor: Colors.amber,
              title: "Themes",
            ),
            MyCustomTile(
              icon: Icons.backup,
              onClick: () => performProfileActions(
                ProfileActions.backup,
              ),
              iconBackGroundColor: Colors.red,
              title: "Backup",
            ),
            MyCustomTile(
              icon: Icons.restore,
              onClick: () => performProfileActions(
                ProfileActions.restore,
              ),
              iconBackGroundColor: Colors.green,
              title: "Restore",
            ),
            const SizedBox(
              height: 10.0,
            ),
            const Spacer(),
            Text(
              "Version 2.3.16",
              style: TextStyle(
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
