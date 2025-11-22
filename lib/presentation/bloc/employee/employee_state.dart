import 'package:equatable/equatable.dart';
import '../../../domain/entities/employee.dart';

abstract class EmployeeState extends Equatable {
  const EmployeeState();

  @override
  List<Object> get props => [];
}

class EmployeeInitial extends EmployeeState {
  const EmployeeInitial();
}

class EmployeeLoading extends EmployeeState {
  const EmployeeLoading();
}

class EmployeeLoaded extends EmployeeState {
  final List<Employee> employees;
  final List<Employee> filteredEmployees;
  final String? errorMessage;

  const EmployeeLoaded({
    required this.employees,
    required this.filteredEmployees,
    this.errorMessage,
  });

  EmployeeLoaded copyWith({
    List<Employee>? employees,
    List<Employee>? filteredEmployees,
    String? errorMessage,
  }) {
    return EmployeeLoaded(
      employees: employees ?? this.employees,
      filteredEmployees: filteredEmployees ?? this.filteredEmployees,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object> get props => [employees, filteredEmployees, errorMessage ?? ''];
}

class EmployeeError extends EmployeeState {
  final String message;

  const EmployeeError(this.message);

  @override
  List<Object> get props => [message];
}

class EmployeeOperationSuccess extends EmployeeState {
  final String message;

  const EmployeeOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class EmployeeOperationLoading extends EmployeeState {
  const EmployeeOperationLoading();
}

