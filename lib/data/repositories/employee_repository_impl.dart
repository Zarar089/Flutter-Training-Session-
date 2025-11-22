import 'package:employee_app_v1_spaghetti/data/data_source/local_data_source/realm_db.dart';
import 'package:employee_app_v1_spaghetti/data/data_source/local_storage/shared_pref.dart';
import 'package:employee_app_v1_spaghetti/data/data_source/remote_data_source/firebase_data_source.dart';
import 'package:employee_app_v1_spaghetti/data/models/realm_mdoels/employee_model.dart';
import 'package:employee_app_v1_spaghetti/domain/entities/employee.dart';
import 'package:employee_app_v1_spaghetti/domain/repositories/i_employee_repository.dart';

class EmployeeRepositoryImpl implements IEmployeeRepository {
  final FirebaseDataSource<Employee> _firebaseDataSource;
  final RealmDataSource<EmployeeRealm> _realmDataSource;
  final SharedPreferencesHelper _sharedPreferencesHelper;

  EmployeeRepositoryImpl({
    required FirebaseDataSource<Employee> firebaseDataSource,
    required RealmDataSource<EmployeeRealm> realmDataSource,
    required SharedPreferencesHelper sharedPreferencesHelper,
  })  : _firebaseDataSource = firebaseDataSource,
        _realmDataSource = realmDataSource,
        _sharedPreferencesHelper = sharedPreferencesHelper;

  @override
  Future<List<Employee>> getEmployees() async {
    List<Employee> employees;
    try {
      employees = await _firebaseDataSource.getData();

      _realmDataSource.deleteAll();
      for (Employee emp in employees) {
        final empData = EmployeeRealm(
          emp.id,
          emp.name,
          emp.email,
          emp.position,
          emp.department,
          emp.joinDate,
          emp.phone,
          emp.salary,
        );
        _realmDataSource.insert(empData);
      }

      await _sharedPreferencesHelper.setString(
        'last_sync_employees',
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      print('Error fetching from Firebase: $e');
      final realmData = _realmDataSource.getAll();
      employees = realmData.map((emp) {
        return Employee(
          id: emp.id,
          name: emp.name,
          email: emp.email,
          position: emp.position,
          department: emp.department,
          joinDate: emp.joinDate,
          phone: emp.phone,
          salary: emp.salary,
        );
      }).toList();
    }

    return employees;
  }

  @override
  Future<void> addEmployee(Employee employee) async {
    final employeeId = DateTime.now().millisecondsSinceEpoch.toString();
    final employeeData = {
      'name': employee.name,
      'email': employee.email,
      'position': employee.position,
      'department': employee.department,
      'joinDate': employee.joinDate.toIso8601String(),
      'phone': employee.phone,
      'salary': employee.salary,
    };

    await _firebaseDataSource.addData(employeeId, employeeData);

    _realmDataSource.insert(
      EmployeeRealm(
        employeeId,
        employee.name,
        employee.email,
        employee.position,
        employee.department,
        employee.joinDate,
        employee.phone,
        employee.salary,
      ),
    );
  }

  @override
  Future<void> updateEmployee(Employee employee) async {
    final employeeData = {
      'name': employee.name,
      'email': employee.email,
      'position': employee.position,
      'department': employee.department,
      'joinDate': employee.joinDate.toIso8601String(),
      'phone': employee.phone,
      'salary': employee.salary,
    };

    await _firebaseDataSource.updateData(employee.id, employeeData);

    _realmDataSource.insert(
      EmployeeRealm(
        employee.id,
        employee.name,
        employee.email,
        employee.position,
        employee.department,
        employee.joinDate,
        employee.phone,
        employee.salary,
      ),
    );
  }

  @override
  Future<void> deleteEmployee(String id) async {
    await _firebaseDataSource.deleteData(id);

    final emp = _realmDataSource.findById(id);
    if (emp != null) {
      _realmDataSource.delete(emp);
    }
  }

  @override
  Future<Employee?> getEmployeeById(String id) async {
    final realmEmployee = _realmDataSource.findById(id);
    if (realmEmployee != null) {
      return Employee(
        id: realmEmployee.id,
        name: realmEmployee.name,
        email: realmEmployee.email,
        position: realmEmployee.position,
        department: realmEmployee.department,
        joinDate: realmEmployee.joinDate,
        phone: realmEmployee.phone,
        salary: realmEmployee.salary,
      );
    }
    return null;
  }
}
