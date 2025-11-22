import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceDataSource {
  final SharedPreferences _prefs;

  SharedPreferenceDataSource(this._prefs);

  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  // Legacy methods for backward compatibility
  Future<void> checkLastSync() async {
    final lastSync = await _prefs.getString('last_sync_employees');
    if (lastSync != null) {
      print('Last synced: $lastSync');
    }
  }

  Future<void> setLastSyncNow() async {
    await _prefs.setString(
      'last_sync_employees',
      DateTime.now().toIso8601String(),
    );
  }
}
