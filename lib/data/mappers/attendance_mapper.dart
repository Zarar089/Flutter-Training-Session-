import '../../domain/entities/attendance.dart';
import '../../attendance_model.dart' as realm_model;

class AttendanceMapper {
  static Attendance fromRealm(realm_model.Attendance realm) {
    return Attendance(
      id: realm.id,
      employeeId: realm.employeeId,
      employeeName: realm.employeeName,
      date: realm.date,
      checkInTime: realm.checkInTime,
      checkOutTime: realm.checkOutTime,
      totalHours: realm.totalHours,
      status: realm.status,
    );
  }

  static realm_model.Attendance toRealm(Attendance attendance) {
    return realm_model.Attendance(
      attendance.id,
      attendance.employeeId,
      attendance.employeeName,
      attendance.date,
      attendance.checkInTime,
      attendance.totalHours,
      attendance.status,
      checkOutTime: attendance.checkOutTime,
    );
  }

  static Attendance fromMap(String id, Map<String, dynamic> map) {
    return Attendance(
      id: id,
      employeeId: map['employeeId'] as String,
      employeeName: map['employeeName'] as String,
      date: map['date'] is DateTime
          ? map['date'] as DateTime
          : DateTime.parse(map['date'] as String),
      checkInTime: map['checkInTime'] is DateTime
          ? map['checkInTime'] as DateTime
          : DateTime.parse(map['checkInTime'] as String),
      checkOutTime: map['checkOutTime'] != null
          ? (map['checkOutTime'] is DateTime
              ? map['checkOutTime'] as DateTime
              : DateTime.parse(map['checkOutTime'] as String))
          : null,
      totalHours: (map['totalHours'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] as String,
    );
  }

  static Map<String, dynamic> toMap(Attendance attendance) {
    return {
      'employeeId': attendance.employeeId,
      'employeeName': attendance.employeeName,
      'date': attendance.date.toIso8601String(),
      'checkInTime': attendance.checkInTime.toIso8601String(),
      'checkOutTime': attendance.checkOutTime?.toIso8601String(),
      'totalHours': attendance.totalHours,
      'status': attendance.status,
    };
  }
}

