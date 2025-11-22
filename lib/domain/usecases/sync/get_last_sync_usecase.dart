import '../../repositories/sync_repository.dart';

class GetLastSyncUseCase {
  final SyncRepository repository;

  GetLastSyncUseCase(this.repository);

  Future<DateTime?> call(String key) async {
    return await repository.getLastSyncTime(key);
  }
}

