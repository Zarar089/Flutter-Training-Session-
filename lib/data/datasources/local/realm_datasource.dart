import 'package:realm/realm.dart';
import '../../../core/error/exceptions.dart';

class RealmDataSource<T extends RealmObject> {
  final Realm realm;

  RealmDataSource(this.realm);

  List<T> getAll() {
    try {
      return realm.all<T>().toList();
    } catch (e) {
      throw CacheException('Failed to get all records: $e');
    }
  }

  T? findById(dynamic id) {
    try {
      return realm.find<T>(id);
    } catch (e) {
      throw CacheException('Failed to find record by id: $e');
    }
  }

  void insert(T obj) {
    try {
      realm.write(() {
        realm.add<T>(obj, update: true);
      });
    } catch (e) {
      throw CacheException('Failed to insert record: $e');
    }
  }

  void insertAll(List<T> objects) {
    try {
      realm.write(() {
        for (var obj in objects) {
          realm.add<T>(obj, update: true);
        }
      });
    } catch (e) {
      throw CacheException('Failed to insert records: $e');
    }
  }

  void delete(T obj) {
    try {
      realm.write(() {
        realm.delete<T>(obj);
      });
    } catch (e) {
      throw CacheException('Failed to delete record: $e');
    }
  }

  void deleteAll() {
    try {
      realm.write(() {
        realm.deleteAll<T>();
      });
    } catch (e) {
      throw CacheException('Failed to delete all records: $e');
    }
  }
}