import 'package:equatable/equatable.dart';

abstract class EmployeeDetailEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class EmployeeDetailLoadTriggered extends EmployeeDetailEvent {
  final String employeeId;

  EmployeeDetailLoadTriggered(this.employeeId);

  @override
  List<Object?> get props => [employeeId];
}

class EmployeeDetailDeleteTriggered extends EmployeeDetailEvent {
  final String employeeId;

  EmployeeDetailDeleteTriggered(this.employeeId);

  @override
  List<Object?> get props => [employeeId];
}
