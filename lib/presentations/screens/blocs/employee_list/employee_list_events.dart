import 'package:equatable/equatable.dart';

class EmployeeListEvents extends Equatable {
  @override
  List<Object?> get props => [];
}

class EmployeeListFetchTriggered extends EmployeeListEvents {}

class EmployeeListDeleteTriggered extends EmployeeListEvents {
  final String employeeId;

  EmployeeListDeleteTriggered(this.employeeId);

  @override
  List<Object?> get props => [employeeId];
}
