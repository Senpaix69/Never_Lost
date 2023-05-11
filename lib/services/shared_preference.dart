import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static SharedPreferencesHelper? _instance;
  late SharedPreferences _prefs;
  SharedPreferencesHelper._();

  factory SharedPreferencesHelper() {
    _instance ??= SharedPreferencesHelper._();
    return _instance!;
  }

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
}
