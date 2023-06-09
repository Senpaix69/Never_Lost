import 'package:flutter/material.dart';

const bubbleLight = "bubble_Light";
const bubbleDark = "bubble_Dark";

@immutable
class Bubble {
  static const primaryColor = Colors.deepPurple;
  static const primaryColorDark = Color.fromARGB(255, 85, 48, 150);
  static const primaryColorLight = Color.fromARGB(255, 112, 61, 201);

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    primaryColorDark: primaryColorDark,
    primaryColorLight: primaryColorLight,
    scaffoldBackgroundColor: const Color.fromARGB(255, 13, 7, 38),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
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
    cardColor: const Color.fromARGB(255, 108, 64, 184),
    canvasColor: Colors.deepPurple[300],
    shadowColor: Colors.white,
    indicatorColor: Colors.deepPurple[200],
    secondaryHeaderColor: Colors.white,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 0.0,
      backgroundColor: primaryColor,
    ),
    timePickerTheme: const TimePickerThemeData(
      backgroundColor: primaryColor,
      dialBackgroundColor: primaryColorDark,
      dialHandColor: primaryColorLight,
    ),
  );
}
