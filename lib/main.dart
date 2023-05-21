import 'package:flutter/material.dart';
import 'package:neverlost/pages/main_home.dart';
import 'package:neverlost/services/notification_service.dart';

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
  );
}
