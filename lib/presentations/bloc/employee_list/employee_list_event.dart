import 'package:equatable/equatable.dart';

abstract class EmployeeListEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchEmployeesEvent extends EmployeeListEvent {}

class SearchEmployeesEvent extends EmployeeListEvent {
  final String query;

  SearchEmployeesEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class DeleteEmployeeEvent extends EmployeeListEvent {
  final String employeeId;

  DeleteEmployeeEvent(this.employeeId);

  @override
  List<Object?> get props => [employeeId];
}