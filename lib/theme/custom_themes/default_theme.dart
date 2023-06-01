import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
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
  cardColor: const Color(0xFFE8ACD3),
  buttonTheme: ButtonThemeData(
    colorScheme: ColorScheme.fromSwatch(
      accentColor: const Color(0xFFA1347E),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFFA1347E),
  ),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
);
