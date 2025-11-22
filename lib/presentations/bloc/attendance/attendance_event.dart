// attendance_event.dart
import 'package:equatable/equatable.dart';

abstract class AttendanceEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchAttendanceEvent extends AttendanceEvent {
  final String employeeId;

  FetchAttendanceEvent(this.employeeId);

  @override
  List<Object?> get props => [employeeId];
}

class CheckInEvent extends AttendanceEvent {
  final String employeeId;
  final String employeeName;

  CheckInEvent(this.employeeId, this.employeeName);

  @override
  List<Object?> get props => [employeeId, employeeName];
}

class CheckOutEvent extends AttendanceEvent {
  final String attendanceId;
  final String employeeId;

  CheckOutEvent(this.attendanceId, this.employeeId);

  @override
  List<Object?> get props => [attendanceId, employeeId];
}

class FetchMonthlyStatsEvent extends AttendanceEvent {
  final String employeeId;

  FetchMonthlyStatsEvent(this.employeeId);

  @override
  List<Object?> get props => [employeeId];
}
