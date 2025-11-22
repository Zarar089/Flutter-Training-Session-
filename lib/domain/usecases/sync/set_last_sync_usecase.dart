import '../../repositories/sync_repository.dart';

class SetLastSyncUseCase {
  final SyncRepository repository;

  SetLastSyncUseCase(this.repository);

  Future<void> call(String key, DateTime time) async {
    return await repository.setLastSyncTime(key, time);
  }
}

