import 'package:flutter/material.dart';
import 'package:neverlost/theme/custom_themes/navy_blue.dart';

ColorScheme lightColorScheme = ColorScheme.fromSeed(seedColor: Colors.blue);

class ThemeProvider extends ChangeNotifier {
  final ThemeData _lightTheme = ThemeData.light().copyWith(useMaterial3: true);

  final ThemeData _darkTheme = ThemeData.dark().copyWith(useMaterial3: true);
  ThemeData? _themeData;

  ThemeProvider() {
    _themeData = NavyBlue.navyBlue;
  }

  ThemeData get themeData => _themeData!;
  ThemeData get darkTheme => _darkTheme;
  ThemeData get lightTheme => _lightTheme;
  ThemeData get navyBlue => NavyBlue.navyBlue;

  void toggleTheme() {
    _themeData = _themeData!.brightness == Brightness.light
        ? ThemeData.dark()
        : ThemeData.light();
    notifyListeners();
  }

  void setTheme({required ThemeData theme}) {
    if (theme == _themeData) {
      return;
    }
    _themeData = theme;
    notifyListeners();
  }
}
