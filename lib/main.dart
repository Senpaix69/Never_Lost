import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:neverlost/firebase_options.dart';
import 'package:neverlost/pages/main_home.dart';
import 'package:neverlost/services/notification_service.dart';
import 'package:neverlost/theme/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeData = themeProvider.themeData;
    return MaterialApp(
      theme: themeData,
      debugShowCheckedModeBanner: false,
      title: "Never Lost",
      home: const MyHomePage(),
    );
  }
}

ThemeData myTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: Colors.grey,
    colorScheme: const ColorScheme.dark(
      primary: Colors.white,
      secondary: Colors.grey,
    ),
  );
}
