import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import '../../../../domain/entities/employee.dart';

class EmployeeListState extends Equatable{
  final Key key = UniqueKey();

  @override
  List<Object?> get props => [key];
}

class EmployeeListInitial extends EmployeeListState{

}

class EmployeeListLoading extends EmployeeListState{

}

class EmployeeListLoaded extends EmployeeListState{
  final List<Employee> employees;

  EmployeeListLoaded(this.employees);
  @override
  List<Object?> get props => [employees, key];
}

class NoEmployeeFound extends EmployeeListState{

}

class EmployeeListError extends EmployeeListState{
  final String message;

  EmployeeListError(this.message);
  @override
  List<Object?> get props => [message, key];
}

