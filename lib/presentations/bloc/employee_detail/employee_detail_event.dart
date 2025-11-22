import 'package:equatable/equatable.dart';

abstract class EmployeeDetailEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class DeleteEmployeeDetailEvent extends EmployeeDetailEvent {
  final String employeeId;

  DeleteEmployeeDetailEvent(this.employeeId);

  @override
  List<Object?> get props => [employeeId];
}