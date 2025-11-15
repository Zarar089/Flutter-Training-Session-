import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceDb {


   SharedPreferences? _pref;
   Future<SharedPreferences>getInstance() async{
    if(_pref==null){
       _pref = await SharedPreferences.getInstance();
      return _pref!;
    }
   
    return _pref!;
   } 

  Future<void> setString(String key, String value) async {
    await getInstance(); 
    await _pref!.setString(key, value); 
  
  }
   Future<String?> getString(String key) async {
    await getInstance();
    return _pref!.getString(key); 
  }
   Future<void> setBoolean(String key, bool value) async {
    await getInstance(); 
    await _pref!.setBool(key, value); 
  
  }
   Future<bool?> getBoolean(String key) async {
    await getInstance();
    return _pref!.getBool(key); 
  }
  
}