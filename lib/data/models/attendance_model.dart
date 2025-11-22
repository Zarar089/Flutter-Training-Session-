import '../../domain/entities/attendance_entity.dart';

class AttendanceModel extends AttendanceEntity {
  const AttendanceModel({
    required String id,
    required String employeeId,
    required String employeeName,
    required DateTime date,
    required DateTime checkInTime,
    DateTime? checkOutTime,
    required double totalHours,
    required String status,
  }) : super(
          id: id,
          employeeId: employeeId,
          employeeName: employeeName,
          date: date,
          checkInTime: checkInTime,
          checkOutTime: checkOutTime,
          totalHours: totalHours,
          status: status,
        );

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      employeeName: json['employeeName'] as String,
      date: DateTime.parse(json['date'] as String),
      checkInTime: DateTime.parse(json['checkInTime'] as String),
      checkOutTime: json['checkOutTime'] != null
          ? DateTime.parse(json['checkOutTime'] as String)
          : null,
      totalHours: (json['totalHours'] as num).toDouble(),
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'date': date.toIso8601String(),
      'checkInTime': checkInTime.toIso8601String(),
      'checkOutTime': checkOutTime?.toIso8601String(),
      'totalHours': totalHours,
      'status': status,
    };
  }

  factory AttendanceModel.fromEntity(AttendanceEntity entity) {
    return AttendanceModel(
      id: entity.id,
      employeeId: entity.employeeId,
      employeeName: entity.employeeName,
      date: entity.date,
      checkInTime: entity.checkInTime,
      checkOutTime: entity.checkOutTime,
      totalHours: entity.totalHours,
      status: entity.status,
    );
  }
}