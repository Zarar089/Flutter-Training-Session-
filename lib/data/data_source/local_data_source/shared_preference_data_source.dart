import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceDataSource {
  final SharedPreferences _prefs;
  static const String _lastSyncEmployeesKey = 'last_sync_employees';

  SharedPreferenceDataSource(this._prefs);

  Future<void> checkLastSync() async {
    final lastSync = await _prefs.getString(_lastSyncEmployeesKey);
    if (lastSync != null) {
      // Consider using a dedicated logger instead of print for production code.
      print('Last synced: $lastSync');
    }
  }

  Future<void> setLastSyncNow() async {
    await _prefs.setString(
      _lastSyncEmployeesKey,
      DateTime.now().toIso8601String(),
    );
  }
}


