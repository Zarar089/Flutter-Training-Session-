
import 'package:employee_app_v1_spaghetti/data/data_source/local_data_source/realm_db.dart';
import 'package:employee_app_v1_spaghetti/data/data_source/local_storage/shared_pref.dart';
import 'package:employee_app_v1_spaghetti/data/data_source/remote_data_source/firebase_data_source.dart';
import 'package:employee_app_v1_spaghetti/domain/entities/employee.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:realm/realm.dart';

import '../../data/models/realm_mdoels/employee_model.dart';

class EmployeeUseCase{

  late FirebaseDataSource<Employee> _firebaseDataSource;
  late RealmDataSource<EmployeeRealm> _realmDataSource;
  late SharedPreferencesHelper _sharedPreferencesHelper;

  EmployeeUseCase(){
    final DatabaseReference firebaseRef = FirebaseDatabase.instance.ref('employees');
    _firebaseDataSource = FirebaseDataSource(firebaseRef);
    final config = Configuration.local([EmployeeRealm.schema]);
    _realmDataSource = RealmDataSource(Realm(config));
    _sharedPreferencesHelper = SharedPreferencesHelper();
  }

  Future<List<Map<String, Object>>> fetchEmployeeData() async{
    List<Map<String, Object>> employees;
    try{
      employees = await _firebaseDataSource.getData();

      _realmDataSource.deleteAll();
      for (var emp in employees) {
        final empDate = EmployeeRealm(
          emp['id'] as String,
          emp['name'] as String,
          emp['email'] as String,
          emp['position'] as String,
          emp['department'] as String,
          emp['joinDate'] as DateTime,
          emp['phone'] as String,
          emp['salary'] as double,
        );
        _realmDataSource.insert(empDate);
      }

      await _sharedPreferencesHelper.setString(
        'last_sync_employees',
        DateTime.now().toIso8601String(),
      );
    }catch(e){
      final realmData = _realmDataSource.getAll();
      employees = realmData.map((emp) => {
        'id': emp.id,
        'name': emp.name,
        'email': emp.email,
        'position': emp.position,
        'department': emp.department,
        'joinDate': emp.joinDate,
        'phone': emp.phone,
        'salary': emp.salary,
      }).toList();
    }

    return employees;
  }

  Future<void> init() async{
    _sharedPreferencesHelper = await _sharedPreferencesHelper.create();
  }

}