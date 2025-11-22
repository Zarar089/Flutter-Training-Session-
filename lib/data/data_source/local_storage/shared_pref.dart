
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper{

  late SharedPreferences _sharedPreferences;

  Future<SharedPreferencesHelper> create() async{
    _sharedPreferences = await SharedPreferences.getInstance();
    return this;
  }

  Future<void> setDouble(String key,double value) async {
    _sharedPreferences.setDouble(key, value);
  }

  double getDouble(String key){
    return _sharedPreferences.getDouble(key) ?? 0;
  }

  Future<void> setString(String key,String value) async {
    _sharedPreferences.setString(key, value);
  }

  String getString(String key){
    return _sharedPreferences.getString(key) ?? "";
  }

}