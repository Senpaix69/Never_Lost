import 'package:flutter/material.dart';

const pinkAccentLight = "PinkAccent_Light";
const pinkAccentDark = "PinkAccent_Dark";

class PinkAccent {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: const Color(0xFFA1347E),
    primaryColorDark: const Color(0xFFA10D72),
    primaryColorLight: const Color(0xFFF3D3E8),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFA1347E),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
    ),
    cardColor: const Color(0xFFFDD7F0),
    indicatorColor: const Color(0xFFE578C3),
    secondaryHeaderColor: Colors.white,
    buttonTheme: ButtonThemeData(
      colorScheme: ColorScheme.fromSwatch(
        accentColor: const Color(0xFFA1347E),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFA1347E),
    ),
  );
}