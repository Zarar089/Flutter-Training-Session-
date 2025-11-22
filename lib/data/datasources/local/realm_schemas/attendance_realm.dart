import 'package:realm/realm.dart';
part 'attendance_realm.realm.dart';

@RealmModel()
class $AttendanceRealm {
  @PrimaryKey()
  late String id;
  late String employeeId;
  late String employeeName;
  late DateTime date;
  late DateTime checkInTime;
  late DateTime? checkOutTime;
  late double totalHours;
  late String status;
}