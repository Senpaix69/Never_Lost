import 'package:flutter/material.dart';
import 'package:neverlost/contants/firebase_contants/firebase_contants.dart';
import 'package:neverlost/pages/profile/setting_screens/about_app.dart';
import 'package:neverlost/pages/profile/setting_screens/about_dev.dart';
import 'package:neverlost/pages/profile/setting_screens/backup_screen.dart';
import 'package:neverlost/pages/profile/setting_screens/restore_screen.dart';
import 'package:neverlost/pages/profile/setting_screens/theme_screen.dart';
import 'package:neverlost/services/database.dart';
import 'package:neverlost/services/firebase_auth_services/firebase_service.dart';
import 'package:neverlost/services/note_services/note.dart';
import 'package:neverlost/services/note_services/todo.dart';
import 'package:neverlost/services/notification_service.dart';
import 'package:neverlost/services/timetable_services/timetable.dart';
import 'package:neverlost/utils.dart' show checkConnection, showSnackBar;
import 'package:neverlost/widgets/animate_route.dart' show SlideRightRoute;
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
  late final List<Note> _notes;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _timetables = _db.cachedTimeTables;
      _todos = _db.cachedTodos;
      _notes = _db.cachedNotes;
    });
  }

  void notConnectedToInternet() {
    LoadingScreen.instance().hide();

    errorDialogue(
      context: context,
      title: "No Internet Connection",
      message: "You are not connected to internet",
    );
  }

  Future<void> makeBackUp({required Map<String, bool> userChoice}) async {
    showLoading(message: "Checking connection...", title: "Connectivity Check");
    if (!await checkConnection()) {
      notConnectedToInternet();
      return;
    }
    if (userChoice[timetableColumn]!) {
      showLoading(
        title: "Timetables",
        message: "Timetables backup is in progress\nPlease wait...",
      );
      await _firebase.uploadTimetables(
        timetables: _timetables,
        callback: (value) => showLoading(
          title: "Timetables",
          message: "Timetables $value",
        ),
      );
    }

    if (userChoice[todoColumn]!) {
      showLoading(
        title: "Todos",
        message: "Todos backup is in progress\nPlease wait......",
      );
      await _firebase.uploadTodos(
        todos: _todos,
        callback: (value) => showLoading(
          title: "Todos",
          message: "Todos $value",
        ),
      );
    }

    if (userChoice[noteColumn]!) {
      showLoading(
        title: "Notes",
        message: "Notes backup is in progress\nPlease wait......",
      );
      await _firebase.uploadNotes(
        notes: _notes,
        callback: (value) => showLoading(
          title: "Notes",
          message: "Notes $value",
        ),
      );
    }
    LoadingScreen.instance().hide();
    showSnak(message: "Backup saved successfully!");
  }

  void showLoading({required String message, required String title}) =>
      LoadingScreen.instance().show(
        context: context,
        title: title,
        text: message,
      );

  void showSnak({required String message}) => showSnackBar(context, message);
  void showErrorDialog({required String title, required String message}) =>
      errorDialogue(
        context: context,
        message: message,
        title: title,
      );

  Future<void> restoreBackup({required Map<String, bool> userChoice}) async {
    showLoading(message: "Checking connection...", title: "Connectivity Check");
    if (!await checkConnection()) {
      notConnectedToInternet();
      return;
    }

    if (userChoice[timetableColumn]!) {
      await _db.cleanTimeTable();
      showLoading(
        title: "Timetables",
        message: "Fetching timetables\nPlease wait...",
      );
      final List<TimeTable> allTimeTables = await _firebase.getAllTimeTables();
      for (final timetable in allTimeTables) {
        await _db.insertTimeTable(
          subject: timetable.subject,
          professor: timetable.professor,
          daytimes: timetable.dayTime,
        );
      }
    }

    if (userChoice[todoColumn]!) {
      await _db.cleanTotoTable();
      showLoading(title: "Todos", message: "Fetching todos\nPlease wait...");
      final List<Todo> allTodos = await _firebase.getAllTodos();
      for (final todo in allTodos) {
        await _db.insertTodo(todo: todo);
      }
    }

    if (userChoice[noteColumn]!) {
      showLoading(title: "Notes", message: "Fetching notes\nPlease wait...");
    }

    await NotificationService.cancelALLScheduleNotification();

    LoadingScreen.instance().hide();
    showSnak(message: "Restoration completed!");
  }

  void performProfileActions(ProfileActions action) async {
    if (_firebase.user == null) {
      errorDialogue(
        context: context,
        message: "You need to login first to perform this action!",
        title: "No User Found",
      );
      return;
    }
    switch (action) {
      case ProfileActions.backup:
        final userChoice = await Navigator.of(context).push(
          SlideRightRoute(page: const BackupScreen()),
        );
        if (userChoice != null) {
          await makeBackUp(userChoice: userChoice);
        }
        break;
      case ProfileActions.restore:
        final userChoice = await Navigator.of(context).push(
          SlideRightRoute(page: const RestoreScreen()),
        );
        if (userChoice != null) {
          await restoreBackup(userChoice: userChoice);
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            MyCustomTile(
              icon: Icons.app_shortcut_rounded,
              onClick: () => Navigator.of(context).push(
                SlideRightRoute(page: const AboutScreen()),
              ),
              iconBackGroundColor: Colors.lightBlue,
              title: "About App",
            ),
            MyCustomTile(
              icon: Icons.person_2,
              onClick: () => Navigator.of(context).push(
                SlideRightRoute(page: const AboutDeveloper()),
              ),
              iconBackGroundColor: Colors.orangeAccent,
              title: "About Developer",
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                height: 40,
              ),
            ),
            MyCustomTile(
              icon: Icons.color_lens,
              onClick: () => Navigator.of(context).push(
                SlideRightRoute(page: const ThemeScreen()),
              ),
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
              "Version 2.4.11",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
