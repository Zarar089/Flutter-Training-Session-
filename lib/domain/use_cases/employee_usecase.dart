import 'package:employee_app_v1_spaghetti/data/data_source/local_data_source/realm_db.dart';
import 'package:employee_app_v1_spaghetti/data/data_source/local_storage/shared_pref.dart';
import 'package:employee_app_v1_spaghetti/data/data_source/remote_data_source/firebase_data_source.dart';
import 'package:employee_app_v1_spaghetti/domain/entities/employee.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:realm/realm.dart';

import '../../data/models/realm_mdoels/employee_model.dart';

class EmployeeUseCase {
  late FirebaseDataSource<Employee> _firebaseDataSource;
  late RealmDataSource<EmployeeRealm> _realmDataSource;
  late SharedPreferencesHelper _sharedPreferencesHelper;

  EmployeeUseCase() {
    final DatabaseReference firebaseRef =
        FirebaseDatabase.instance.ref('employees');
    _firebaseDataSource = FirebaseDataSource(firebaseRef);
    final config = Configuration.local([EmployeeRealm.schema]);
    _realmDataSource = RealmDataSource(Realm(config));
    _sharedPreferencesHelper = SharedPreferencesHelper();
  }

  Future<List<Employee>> fetchEmployeeData() async {
    List<Employee> employees;
    try {
      employees = await _firebaseDataSource.getData() as List<Employee>;

      _realmDataSource.deleteAll();
      for (Employee emp in employees) {
        final empDate = EmployeeRealm(
          emp.id,
          emp.name,
          emp.email,
          emp.position,
          emp.department,
          emp.joinDate,
          emp.phone,
          emp.salary,
        );
        _realmDataSource.insert(empDate);
      }

      await _sharedPreferencesHelper.setString(
        'last_sync_employees',
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
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
            salary: emp.salary);
      }).toList();
    }

    return employees;
  }

  Future<void> init() async {
    _sharedPreferencesHelper = await _sharedPreferencesHelper.create();
  }
}
