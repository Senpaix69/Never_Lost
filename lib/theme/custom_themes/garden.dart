import 'package:flutter/material.dart';

const gardenLight = "garden_Light";
const gardenDark = "garden_Dark";

@immutable
class Garden {
  static const primaryColor = Color.fromARGB(255, 13, 77, 15);
  static const primaryColorDark = Color.fromARGB(255, 11, 58, 25);
  static const primaryColorLight = Color.fromARGB(255, 18, 114, 22);

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    primaryColorDark: primaryColorDark,
    primaryColorLight: primaryColorLight,
    scaffoldBackgroundColor: const Color.fromARGB(255, 5, 27, 7),
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
    cardColor: Colors.green[400],
    canvasColor: Colors.green[300],
    shadowColor: Colors.white,
    indicatorColor: Colors.green[200],
    secondaryHeaderColor: Colors.white,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 0.0,
      backgroundColor: primaryColor,
    ),
    timePickerTheme: const TimePickerThemeData(
      backgroundColor: primaryColor,
      dialBackgroundColor: primaryColorDark,
      dialHandColor: Colors.greenAccent,
    ),
  );
}
