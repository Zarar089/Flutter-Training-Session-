import 'package:equatable/equatable.dart';

class AttendanceEntity extends Equatable {
  final String id;
  final String employeeId;
  final String employeeName;
  final DateTime date;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final double totalHours;
  final String status;

  const AttendanceEntity({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.date,
    required this.checkInTime,
    this.checkOutTime,
    required this.totalHours,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        employeeId,
        employeeName,
        date,
        checkInTime,
        checkOutTime,
        totalHours,
        status,
      ];

  AttendanceEntity copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    DateTime? date,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    double? totalHours,
    String? status,
  }) {
    return AttendanceEntity(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      date: date ?? this.date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      totalHours: totalHours ?? this.totalHours,
      status: status ?? this.status,
    );
  }
}