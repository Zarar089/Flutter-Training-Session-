import 'package:realm/realm.dart';
part 'employee_realm.g.dart';

@RealmModel()
class _EmployeeRealm {
  @PrimaryKey()
  late String id;
  late String name;
  late String email;
  late String position;
  late String department;
  late String joinDate;
  late String phone;
  late int salary;
}