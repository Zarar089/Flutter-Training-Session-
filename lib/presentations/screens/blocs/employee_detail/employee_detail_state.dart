import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import '../../../../domain/entities/employee.dart';

abstract class EmployeeDetailState extends Equatable {
  final Key key = UniqueKey();

  @override
  List<Object?> get props => [key];
}

class EmployeeDetailInitial extends EmployeeDetailState {}

class EmployeeDetailLoading extends EmployeeDetailState {}

class EmployeeDetailLoaded extends EmployeeDetailState {
  final Employee employee;

  EmployeeDetailLoaded(this.employee);

  @override
  List<Object?> get props => [employee, key];
}

class EmployeeDetailDeleting extends EmployeeDetailState {}

class EmployeeDetailDeleted extends EmployeeDetailState {}

class EmployeeDetailError extends EmployeeDetailState {
  final String message;

  EmployeeDetailError(this.message);

  @override
  List<Object?> get props => [message, key];
}
