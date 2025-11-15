
import 'package:realm/realm.dart';
part 'attendance_model.realm.dart';

@RealmModel()
class $Attendance {
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