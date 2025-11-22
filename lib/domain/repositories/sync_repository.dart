abstract class SyncRepository {
  Future<DateTime?> getLastSyncTime(String key);
  Future<void> setLastSyncTime(String key, DateTime time);
}

