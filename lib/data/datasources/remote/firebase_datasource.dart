import 'package:firebase_database/firebase_database.dart';
import '../../../core/error/exceptions.dart';

class FirebaseDataSource {
  final DatabaseReference firebaseRef;

  FirebaseDataSource(this.firebaseRef);

  Future<Map<String, dynamic>> getAll() async {
    try {
      final snapshot = await firebaseRef.get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
      return {};
    } catch (e) {
      throw ServerException('Failed to fetch data from Firebase: $e');
    }
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    try {
      final snapshot = await firebaseRef.child(id).get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
      return null;
    } catch (e) {
      throw ServerException('Failed to fetch data by id from Firebase: $e');
    }
  }

  Future<void> insert(String id, Map<String, dynamic> data) async {
    try {
      await firebaseRef.child(id).set(data);
    } catch (e) {
      throw ServerException('Failed to insert data to Firebase: $e');
    }
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    try {
      await firebaseRef.child(id).update(data);
    } catch (e) {
      throw ServerException('Failed to update data in Firebase: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await firebaseRef.child(id).remove();
    } catch (e) {
      throw ServerException('Failed to delete data from Firebase: $e');
    }
  }
}