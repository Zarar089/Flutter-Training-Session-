import 'package:realm/realm.dart';
import '../../models/realm_models/employee_realm.dart';
import '../../../domain/entities/employee.dart';

class RealmEmployeeDataSource {
  late final Realm realm;

  RealmEmployeeDataSource() {
    final config = Configuration.local([EmployeeRealm.schema]);
    realm = Realm(config);
  }

  void cacheEmployees(List<Employee> employees) {
    realm.write(() {
      realm.deleteAll<EmployeeRealm>();
      for (final emp in employees) {
        realm.add(EmployeeRealm()
          ..id = emp.id
          ..name = emp.name
          ..email = emp.email
          ..position = emp.position
          ..department = emp.department
          ..joinDate = emp.joinDate
          ..phone = emp.phone
          ..salary = emp.salary);
      }
    });
  }

  List<Employee> getCachedEmployees() {
    return realm.all<EmployeeRealm>().map((r) => Employee(
      id: r.id,
      name: r.name,
      email: r.email,
      position: r.position,
      department: r.department,
      joinDate: r.joinDate,
      phone: r.phone,
      salary: r.salary,
    )).toList();
  }

  void deleteEmployee(String id) {
    realm.write(() {
      final obj = realm.find<EmployeeRealm>(id);
      if (obj != null) realm.delete(obj);
    });
  }

  void close() => realm.close();
}