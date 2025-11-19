import 'package:firebase_database/firebase_database.dart';
import '../../../domain/entities/employee.dart';

class FirebaseEmployeeDataSource {
  final DatabaseReference ref = FirebaseDatabase.instance.ref('employees');

  Future<List<Employee>> getEmployees() async {
    final snapshot = await ref.get();
    if (!snapshot.exists) return [];

    final Map<dynamic, dynamic> data = snapshot.value as Map;
    return data.entries.map((e) {
      final map = e.value as Map<dynamic, dynamic>;
      return Employee(
        id: e.key,
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        position: map['position'] ?? '',
        department: map['department'] ?? '',
        joinDate: map['joinDate'] ?? '',
        phone: map['phone'] ?? '',
        salary: map['salary'] ?? 0,
      );
    }).toList();
  }

  Future<void> deleteEmployee(String id) => ref.child(id).remove();
  Future<void> addEmployee(Employee emp) => ref.child(emp.id).set(emp.toMap());
}