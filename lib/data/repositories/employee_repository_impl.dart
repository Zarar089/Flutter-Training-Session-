import 'package:firebase_database/firebase_database.dart';
import 'package:realm/realm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/employee.dart';
import '../../domain/repositories/employee_repository.dart';
import '../mappers/employee_mapper.dart';
import '../models/reals_models/employee/employee_model.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final DatabaseReference _firebaseRef;
  final Realm _realm;

  EmployeeRepositoryImpl(this._firebaseRef, this._realm);

  @override
  Future<List<Employee>> getEmployees() async {
    try {
      // Try Firebase first
      final snapshot = await _firebaseRef.get();
      List<Employee> employees = [];

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        employees = data.entries.map((entry) {
          return EmployeeMapper.fromMap(
            entry.key as String,
            entry.value as Map<dynamic, dynamic>,
          );
        }).toList();

        // Save sync time
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'last_sync_employees',
          DateTime.now().toIso8601String(),
        );

        // Cache to Realm
        _realm.write(() {
          _realm.deleteAll<EmployeeRealm>();
          for (var emp in employees) {
            _realm.add(EmployeeMapper.toRealm(emp), update: true);
          }
        });
      } else {
        // Load from Realm if Firebase is empty
        final realmData = _realm.all<EmployeeRealm>();
        employees = realmData.map((emp) => EmployeeMapper.fromRealm(emp)).toList();
      }

      return employees;
    } catch (e) {
      // Fallback to Realm on error
      final realmData = _realm.all<EmployeeRealm>();
      return realmData.map((emp) => EmployeeMapper.fromRealm(emp)).toList();
    }
  }

  @override
  Future<Employee> getEmployeeById(String id) async {
    try {
      final snapshot = await _firebaseRef.child(id).get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return EmployeeMapper.fromMap(id, data);
      }
    } catch (e) {
      // Fallback to Realm
    }

    final realmEmp = _realm.find<EmployeeRealm>(id);
    if (realmEmp != null) {
      return EmployeeMapper.fromRealm(realmEmp);
    }

    throw Exception('Employee not found');
  }

  @override
  Future<void> addEmployee(Employee employee) async {
    try {
      // Save to Firebase
      await _firebaseRef.child(employee.id).set(EmployeeMapper.toMap(employee));

      // Save to Realm
      _realm.write(() {
        _realm.add(EmployeeMapper.toRealm(employee), update: true);
      });
    } catch (e) {
      // Still save to Realm even if Firebase fails
      _realm.write(() {
        _realm.add(EmployeeMapper.toRealm(employee), update: true);
      });
      rethrow;
    }
  }

  @override
  Future<void> updateEmployee(Employee employee) async {
    await addEmployee(employee); // Same logic for add/update
  }

  @override
  Future<void> deleteEmployee(String id) async {
    try {
      // Delete from Firebase
      await _firebaseRef.child(id).remove();

      // Delete from Realm
      _realm.write(() {
        final emp = _realm.find<EmployeeRealm>(id);
        if (emp != null) {
          _realm.delete(emp);
        }
      });
    } catch (e) {
      // Still delete from Realm even if Firebase fails
      _realm.write(() {
        final emp = _realm.find<EmployeeRealm>(id);
        if (emp != null) {
          _realm.delete(emp);
        }
      });
      rethrow;
    }
  }

  @override
  Future<List<Employee>> searchEmployees(String query) async {
    final employees = await getEmployees();
    if (query.isEmpty) {
      return employees;
    }

    final lowerQuery = query.toLowerCase();
    return employees.where((emp) {
      return emp.name.toLowerCase().contains(lowerQuery) ||
          emp.position.toLowerCase().contains(lowerQuery) ||
          emp.department.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}

