import 'package:realm/realm.dart';
part 'employee_realm.realm.dart';

@RealmModel()
class $EmployeeRealm {
  @PrimaryKey()
  late String id;
  late String name;
  late String email;
  late String position;
  late String department;
  late DateTime joinDate;
  late String phone;
  late double salary;
}