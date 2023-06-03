import 'package:flutter/material.dart';

@immutable
class NavyBlue {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF124B52),
    primaryColorDark: const Color(0xFF0C454B),
    primaryColorLight: const Color(0xFF1B9BAA),
    scaffoldBackgroundColor: const Color(0xFF012F34),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF124B52),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateColor.resolveWith(
          (states) => Colors.white,
        ),
      ),
    ),
    cardColor: const Color(0xFF146C76),
    canvasColor: const Color(0xFF00737F),
    shadowColor: Colors.white,
    indicatorColor: const Color(0xFF90EDF7),
    secondaryHeaderColor: Colors.white,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 0.0,
      backgroundColor: Color(0xFF0C454B),
      splashColor: Color(0xFF146C76),
      focusColor: Color(0xFF146C76),
      hoverColor: Color(0xFF146C76),
      foregroundColor: Color(0xFF146C76),
    ),
  );
}
