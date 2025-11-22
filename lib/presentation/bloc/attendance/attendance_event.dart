import 'package:equatable/equatable.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object> get props => [];
}

class LoadAttendance extends AttendanceEvent {
  const LoadAttendance();
}

class LoadEmployees extends AttendanceEvent {
  const LoadEmployees();
}

class SelectEmployee extends AttendanceEvent {
  final String employeeId;

  const SelectEmployee(this.employeeId);

  @override
  List<Object> get props => [employeeId];
}

class CheckIn extends AttendanceEvent {
  final String employeeId;
  final String employeeName;

  const CheckIn(this.employeeId, this.employeeName);

  @override
  List<Object> get props => [employeeId, employeeName];
}

class CheckOut extends AttendanceEvent {
  final String employeeId;

  const CheckOut(this.employeeId);

  @override
  List<Object> get props => [employeeId];
}

class RefreshAttendance extends AttendanceEvent {
  const RefreshAttendance();
}

class CalculateMonthlyHours extends AttendanceEvent {
  final String employeeId;

  const CalculateMonthlyHours(this.employeeId);

  @override
  List<Object> get props => [employeeId];
}

