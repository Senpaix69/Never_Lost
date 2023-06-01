import 'package:flutter/material.dart';

final ColorScheme _colorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF0C2C4B),
);

@immutable
class NavyBlue {
  static final ThemeData navyBlue = ThemeData(
    useMaterial3: true,
    colorScheme: _colorScheme,
    scaffoldBackgroundColor: const Color(0xFF0C2C4B),
    popupMenuTheme: const PopupMenuThemeData(
      color: Color(0xFF174C81),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF0C56A0),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: _colorScheme.primary,
    ),
    appBarTheme: AppBarTheme(
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor:
          ColorScheme.fromSeed(seedColor: const Color(0xFF0C2C4B)).primary,
    ),
    dialogBackgroundColor: _colorScheme.background,
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: Colors.white,
      ),
      titleMedium: TextStyle(
        color: Colors.white,
      ),
      titleSmall: TextStyle(
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        color: Colors.white,
      ),
      bodySmall: TextStyle(
        color: Colors.white,
      ),
      labelLarge: TextStyle(
        color: Colors.white,
      ),
      labelMedium: TextStyle(
        color: Colors.white,
      ),
      labelSmall: TextStyle(
        color: Colors.white,
      ),
    ),
  );
}
