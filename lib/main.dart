import 'package:flutter/material.dart';
import 'package:my_timetable/pages/main_home.dart';
import 'package:my_timetable/services/notification_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService.initialize();
  runApp(
    MaterialApp(
      theme: myTheme(),
      debugShowCheckedModeBanner: false,
      title: "Never Lost",
      home: const MyHomePage(),
    ),
  );
}

ThemeData myTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.lightBlue,
    colorScheme: const ColorScheme.dark(
      primary: Colors.lightBlue,
      secondary: Colors.lightBlue,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black),
      bodySmall: TextStyle(color: Colors.black),
      labelLarge: TextStyle(color: Colors.black),
      displayLarge: TextStyle(color: Colors.black),
      displayMedium: TextStyle(color: Colors.black),
      displaySmall: TextStyle(color: Colors.black),
    ),
  );
}
