import 'package:flutter/material.dart';

const greyFoldLight = "greyFold_Light";
const greyFoldDark = "greyFold_Dark";

@immutable
class GreyFold {
  static const primaryColor = Color(0xFF363636);
  static const primaryColorDark = Color(0xFF262626);
  static const primaryColorLight = Color(0xFF5B5B5B);

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    primaryColorDark: primaryColorDark,
    primaryColorLight: primaryColorLight,
    scaffoldBackgroundColor: const Color(0xFF000000),
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
    cardColor: const Color(0xFF4D4D4D),
    canvasColor: const Color(0xFF5B5B5B),
    shadowColor: Colors.white,
    indicatorColor: const Color(0xFFA9A9A9),
    secondaryHeaderColor: Colors.white,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 0.0,
      backgroundColor: primaryColor,
    ),
    timePickerTheme: const TimePickerThemeData(
      backgroundColor: primaryColor,
      dialBackgroundColor: primaryColorDark,
      dialHandColor: Color(0xFF818181),
    ),
  );
}
