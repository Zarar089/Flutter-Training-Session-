import 'package:employee_app_v1_spaghetti/domain/entities/base_entity.dart';
import 'package:employee_app_v1_spaghetti/domain/entities/employee.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseDataSource<T extends BaseEntity> {
  final DatabaseReference _firebaseRef;
  FirebaseDataSource(this._firebaseRef);

  Future<List<Employee>> getData() async {
    final snapshot = await _firebaseRef.get();
    List<Employee> employees = [];
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      employees = data.entries.map((entry) {
        Employee employee = Employee.empty();
        // Create a new map with the id included
        final employeeData = Map<dynamic, dynamic>.from(entry.value);
        employeeData['id'] = entry.key; // Add the id from the key
        return employee.fromMap(employeeData) as Employee;
      }).toList();
    }
    return employees;
  }

  Future<void> addData(String id, Map<String, dynamic> data) async {
    await _firebaseRef.child(id).set(data);
  }

  Future<void> updateData(String id, Map<String, dynamic> data) async {
    await _firebaseRef.child(id).set(data);
  }

  Future<void> deleteData(String id) async {
    await _firebaseRef.child(id).remove();
  }
}
