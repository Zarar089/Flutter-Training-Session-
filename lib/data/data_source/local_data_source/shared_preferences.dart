import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesDataSource<T> {
  static Future<void> setStr(String key, String value) async
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }
  Future<String?> getStr(String key) async
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
}