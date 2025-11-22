import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/error/exceptions.dart';

class SharedPrefDataSource {
  final SharedPreferences sharedPreferences;

  SharedPrefDataSource(this.sharedPreferences);

  Future<void> setString(String key, String value) async {
    try {
      await sharedPreferences.setString(key, value);
    } catch (e) {
      throw CacheException('Failed to save string: $e');
    }
  }

  String? getString(String key) {
    try {
      return sharedPreferences.getString(key);
    } catch (e) {
      throw CacheException('Failed to get string: $e');
    }
  }

  Future<void> setDouble(String key, double value) async {
    try {
      await sharedPreferences.setDouble(key, value);
    } catch (e) {
      throw CacheException('Failed to save double: $e');
    }
  }

  double? getDouble(String key) {
    try {
      return sharedPreferences.getDouble(key);
    } catch (e) {
      throw CacheException('Failed to get double: $e');
    }
  }

  Future<void> setBool(String key, bool value) async {
    try {
      await sharedPreferences.setBool(key, value);
    } catch (e) {
      throw CacheException('Failed to save bool: $e');
    }
  }

  bool? getBool(String key) {
    try {
      return sharedPreferences.getBool(key);
    } catch (e) {
      throw CacheException('Failed to get bool: $e');
    }
  }

  Future<void> remove(String key) async {
    try {
      await sharedPreferences.remove(key);
    } catch (e) {
      throw CacheException('Failed to remove key: $e');
    }
  }
}