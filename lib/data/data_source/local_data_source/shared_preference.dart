import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesLocal<T> {
  final SharedPreferences _prefs;
  static const String lastSyncKey = 'last_sync_employees';

  SharedPreferencesLocal(this._prefs);

  Future<void> checkLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getString('last_sync_employees');
    if (lastSync != null) {
      print('Last synced: $lastSync');
    }
  }

  Future<void> setLastSync() async {
    await _prefs.setString(
      lastSyncKey,
      DateTime.now().toIso8601String(),
    );
  }
}
