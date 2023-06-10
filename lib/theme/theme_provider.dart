import 'package:flutter/material.dart';
import 'package:neverlost/theme/custom_themes/grey_fold.dart';
import 'package:neverlost/theme/custom_themes/navy_blue.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData? _themeData;
  final String themePreferenceKey = 'theme';

  ThemeProvider() {
    _themeData = NavyBlue.darkTheme;
    _loadThemeFromPrefs();
  }

  ThemeData get themeData => _themeData!;
  ThemeData get navyBlue => NavyBlue.darkTheme;
  ThemeData get blackFold => GreyFold.darkTheme;

  void setTheme({required ThemeData theme}) async {
    _themeData = theme;
    await _saveThemeToPrefs();
    notifyListeners();
  }

  Future<void> _loadThemeFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedTheme = prefs.getString(themePreferenceKey);

    if (savedTheme == navyBlueDark) {
      _themeData = NavyBlue.darkTheme;
    } else if (savedTheme == greyFoldDark) {
      _themeData = GreyFold.darkTheme;
    }
    notifyListeners();
  }

  Future<void> _saveThemeToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_themeData == NavyBlue.darkTheme) {
      await prefs.setString(themePreferenceKey, navyBlueDark);
      return;
    }

    if (_themeData == GreyFold.darkTheme) {
      await prefs.setString(themePreferenceKey, greyFoldDark);
    }
  }

  void getThemeFromSharedPref({String? theme}) {
    if (theme == navyBlueLight) {
      _themeData = NavyBlue.darkTheme;
    }
    if (theme == greyFoldDark) {
      _themeData = GreyFold.darkTheme;
    }

    notifyListeners();
  }
}
