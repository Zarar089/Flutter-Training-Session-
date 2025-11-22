import '../../domain/entities/attendance.dart' as domain;
import '../models/reals_models/attendence/attendance_model.dart' as realm_model;

class AttendanceMapper {
  static domain.Attendance fromRealm(realm_model.Attendance realm) {
    return domain.Attendance(
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

  static realm_model.Attendance toRealm(domain.Attendance attendance) {
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

  static domain.Attendance fromMap(String id, Map<dynamic, dynamic> data) {
    return domain.Attendance(
      id: id,
      employeeId: data['employeeId'] as String,
      employeeName: data['employeeName'] as String,
      date: DateTime.parse(data['date'] as String),
      checkInTime: DateTime.parse(data['checkInTime'] as String),
      checkOutTime: data['checkOutTime'] != null
          ? DateTime.parse(data['checkOutTime'] as String)
          : null,
      totalHours: (data['totalHours'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] as String,
    );
  }

  static Map<String, dynamic> toMap(domain.Attendance attendance) {
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

