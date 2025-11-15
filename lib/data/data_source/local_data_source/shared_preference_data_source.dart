import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceDataSource
{
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> setValue(String key, String value) async
  {
    await _prefs?.setString(
      key,
      value,
    );
  }

  Future<String?> getValue(String key) async
  {
    return _prefs?.getString(key);
  }
}