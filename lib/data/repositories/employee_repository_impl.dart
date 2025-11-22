import '../../domain/entities/employee.dart';
import '../../domain/repositories/employee_repository.dart';
import '../../domain/repositories/sync_repository.dart';
import '../data_source/remote_data_source/firebase_data_source.dart';
import '../data_source/local_data_source/realm_db.dart';
import '../models/realm_mdoels/employee_model.dart';
import '../mappers/employee_mapper.dart';
import 'package:firebase_database/firebase_database.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final FirebaseDataSource<Map<String, dynamic>> firebaseDataSource;
  final RealmDataSource<EmployeeRealm> realmDataSource;
  final SyncRepository syncRepository;
  final DatabaseReference firebaseRef;

  EmployeeRepositoryImpl({
    required this.firebaseDataSource,
    required this.realmDataSource,
    required this.syncRepository,
    required this.firebaseRef,
  });

  @override
  Future<List<Employee>> getEmployees() async {
    try {
      // Try Firebase first
      final snapshot = await firebaseRef.get();
      
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final employees = data.entries.map((entry) {
          final value = entry.value as Map<dynamic, dynamic>;
          return EmployeeMapper.fromMap(
            entry.key as String,
            {
              'name': value['name'] as String,
              'email': value['email'] as String,
              'position': value['position'] as String,
              'department': value['department'] as String,
              'joinDate': value['joinDate'] as String,
              'phone': value['phone'] as String,
              'salary': (value['salary'] as num).toDouble(),
            },
          );
        }).toList();

        // Cache to Realm
        realmDataSource.realm.write(() {
          realmDataSource.realm.deleteAll<EmployeeRealm>();
          for (var emp in employees) {
            realmDataSource.insert(EmployeeMapper.toRealm(emp));
          }
        });

        // Save sync time
        await syncRepository.setLastSyncTime('last_sync_employees', DateTime.now());

        return employees;
      } else {
        // Fallback to Realm if Firebase is empty
        return _loadFromRealm();
      }
    } catch (e) {
      // Fallback to Realm if Firebase fails
      return _loadFromRealm();
    }
  }

  List<Employee> _loadFromRealm() {
    final realmData = realmDataSource.getAll();
    return realmData.map((emp) => EmployeeMapper.fromRealm(emp)).toList();
  }

  @override
  Future<Employee> getEmployeeById(String id) async {
    try {
      final snapshot = await firebaseRef.child(id).get();
      if (snapshot.exists) {
        final value = snapshot.value as Map<dynamic, dynamic>;
        return EmployeeMapper.fromMap(
          id,
          {
            'name': value['name'] as String,
            'email': value['email'] as String,
            'position': value['position'] as String,
            'department': value['department'] as String,
            'joinDate': value['joinDate'] as String,
            'phone': value['phone'] as String,
            'salary': (value['salary'] as num).toDouble(),
          },
        );
      }
    } catch (e) {
      // Fallback to Realm
    }
    
    final realmEmp = realmDataSource.findById(id);
    if (realmEmp != null) {
      return EmployeeMapper.fromRealm(realmEmp);
    }
    
    throw Exception('Employee not found');
  }

  @override
  Future<void> addEmployee(Employee employee) async {
    try {
      // Save to Firebase
      await firebaseRef.child(employee.id).set(EmployeeMapper.toMap(employee));

      // Save to Realm
      realmDataSource.insert(EmployeeMapper.toRealm(employee));
    } catch (e) {
      // Still save to Realm even if Firebase fails
      realmDataSource.insert(EmployeeMapper.toRealm(employee));
      rethrow;
    }
  }

  @override
  Future<void> updateEmployee(Employee employee) async {
    try {
      // Update Firebase
      await firebaseRef.child(employee.id).update(EmployeeMapper.toMap(employee));

      // Update Realm
      realmDataSource.insert(EmployeeMapper.toRealm(employee));
    } catch (e) {
      // Still update Realm even if Firebase fails
      realmDataSource.insert(EmployeeMapper.toRealm(employee));
      rethrow;
    }
  }

  @override
  Future<void> deleteEmployee(String id) async {
    try {
      // Delete from Firebase
      await firebaseRef.child(id).remove();

      // Delete from Realm
      final emp = realmDataSource.findById(id);
      if (emp != null) {
        realmDataSource.delete(emp);
      }
    } catch (e) {
      // Still delete from Realm even if Firebase fails
      final emp = realmDataSource.findById(id);
      if (emp != null) {
        realmDataSource.delete(emp);
      }
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

