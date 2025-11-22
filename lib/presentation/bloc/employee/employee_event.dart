import 'package:equatable/equatable.dart';
import '../../../domain/entities/employee.dart';

abstract class EmployeeEvent extends Equatable {
  const EmployeeEvent();

  @override
  List<Object> get props => [];
}

class LoadEmployees extends EmployeeEvent {
  const LoadEmployees();
}

class SearchEmployees extends EmployeeEvent {
  final String query;

  const SearchEmployees(this.query);

  @override
  List<Object> get props => [query];
}

class AddEmployee extends EmployeeEvent {
  final Employee employee;

  const AddEmployee(this.employee);

  @override
  List<Object> get props => [employee];
}

class UpdateEmployee extends EmployeeEvent {
  final Employee employee;

  const UpdateEmployee(this.employee);

  @override
  List<Object> get props => [employee];
}

class DeleteEmployee extends EmployeeEvent {
  final String id;

  const DeleteEmployee(this.id);

  @override
  List<Object> get props => [id];
}

class RefreshEmployees extends EmployeeEvent {
  const RefreshEmployees();
}

