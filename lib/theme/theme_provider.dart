import 'package:flutter/material.dart';
import 'package:neverlost/theme/custom_themes/navy_blue.dart';
import 'package:neverlost/theme/custom_themes/pink_accent.dart';
import 'package:shared_preferences/shared_preferences.dart';

ColorScheme lightColorScheme = ColorScheme.fromSeed(seedColor: Colors.blue);

class ThemeProvider extends ChangeNotifier {
  ThemeData? _themeData;
  final String themePreferenceKey = 'theme';

  ThemeProvider() {
    _themeData = NavyBlue.lightTheme;
    _loadThemeFromPrefs();
  }

  ThemeData get themeData => _themeData!;
  ThemeData get pinkAccent => PinkAccent.lightTheme;
  ThemeData get navyBlue => NavyBlue.lightTheme;

  void setTheme({required ThemeData theme}) async {
    _themeData = theme;
    await _saveThemeToPrefs();
    notifyListeners();
  }

  Future<void> _loadThemeFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedTheme = prefs.getString(themePreferenceKey);

    if (savedTheme == navyBlueLight) {
      _themeData = NavyBlue.lightTheme;
    }
    if (savedTheme == pinkAccentLight) {
      _themeData = PinkAccent.lightTheme;
    }

    notifyListeners();
  }

  Future<void> _saveThemeToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_themeData == NavyBlue.lightTheme) {
      await prefs.setString(themePreferenceKey, navyBlueLight);
      return;
    }
    if (_themeData == PinkAccent.lightTheme) {
      await prefs.setString(themePreferenceKey, pinkAccentLight);
    }
  }

  void getThemeFromSharedPref({String? theme}) {
    if (theme == navyBlueLight) {
      _themeData = NavyBlue.lightTheme;
    }
    if (theme == pinkAccentLight) {
      _themeData = PinkAccent.lightTheme;
    }
    notifyListeners();
  }
}