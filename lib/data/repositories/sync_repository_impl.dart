import '../../domain/repositories/sync_repository.dart';
import '../data_source/local_data_source/shared_preference_data_source.dart';

class SyncRepositoryImpl implements SyncRepository {
  final SharedPreferenceDataSource sharedPreferenceDataSource;

  SyncRepositoryImpl(this.sharedPreferenceDataSource);

  @override
  Future<DateTime?> getLastSyncTime(String key) async {
    final lastSyncString = await sharedPreferenceDataSource.getString(key);
    if (lastSyncString != null) {
      return DateTime.parse(lastSyncString);
    }
    return null;
  }

  @override
  Future<void> setLastSyncTime(String key, DateTime time) async {
    await sharedPreferenceDataSource.setString(key, time.toIso8601String());
  }
}

