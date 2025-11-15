 import 'package:shared_preferences/shared_preferences.dart';

 class SharedPrefUtils {

  Future<void> setStr(String key, String value) async {
       final SharedPreferences pref = await SharedPreferences.getInstance();
       pref.setString(key, value);
    }

    Future<String?> getStr(String key) async {
        final SharedPreferences pref = await SharedPreferences.getInstance();
        return pref.getString(key);
    }

 }