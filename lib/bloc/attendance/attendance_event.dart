import 'package:equatable/equatable.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

class LoadAttendanceRecords extends AttendanceEvent {
  const LoadAttendanceRecords();
}

class LoadAttendanceByEmployee extends AttendanceEvent {
  final String employeeId;

  const LoadAttendanceByEmployee(this.employeeId);

  @override
  List<Object?> get props => [employeeId];
}

class MarkCheckIn extends AttendanceEvent {
  final String employeeId;
  final String employeeName;

  const MarkCheckIn(this.employeeId, this.employeeName);

  @override
  List<Object?> get props => [employeeId, employeeName];
}

class MarkCheckOut extends AttendanceEvent {
  final String employeeId;

  const MarkCheckOut(this.employeeId);

  @override
  List<Object?> get props => [employeeId];
}

class LoadMonthlyHours extends AttendanceEvent {
  final String employeeId;

  const LoadMonthlyHours(this.employeeId);

  @override
  List<Object?> get props => [employeeId];
}

class RefreshAttendance extends AttendanceEvent {
  const RefreshAttendance();
}

