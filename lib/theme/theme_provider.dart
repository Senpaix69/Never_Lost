import 'package:flutter/material.dart';
import 'package:neverlost/theme/custom_themes/navy_blue.dart';
import 'package:neverlost/theme/custom_themes/pink_accent.dart';

ColorScheme lightColorScheme = ColorScheme.fromSeed(seedColor: Colors.blue);

class ThemeProvider extends ChangeNotifier {
  ThemeData? _themeData;

  ThemeProvider() {
    _themeData = PinkAccent.lightTheme;
  }

  ThemeData get themeData => _themeData!;
  ThemeData get pinkAccent => PinkAccent.lightTheme;
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
