import 'package:flutter/material.dart';
import 'package:my_timetable/constants/routes.dart';
import 'package:my_timetable/pages/add_subject_page.dart';
import 'package:my_timetable/pages/main_home.dart';
import 'package:my_timetable/pages/timetables_page.dart';
import 'package:my_timetable/services/notification_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService.initialize();
  runApp(
    MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.cyan[900],
        colorScheme: const ColorScheme.dark(
          primary: Colors.cyan,
          secondary: Colors.cyan,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
          labelLarge: TextStyle(color: Colors.white),
          displayLarge: TextStyle(color: Colors.white),
          displayMedium: TextStyle(color: Colors.white),
          displaySmall: TextStyle(color: Colors.white),
        ),
      ),
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      title: "Never Lost",
      home: const MyHomePage(),
      routes: {
        timeTablePage: (context) => const TimeTablesPage(),
        addSubjectPage: (context) => const AddSubject(),
      },
    ),
  );
}
