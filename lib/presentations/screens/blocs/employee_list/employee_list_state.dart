import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import '../../../../domain/entities/employee.dart';

class EmployeeListState extends Equatable{
  final Key key = UniqueKey();

  @override
  // TODO: implement props
  List<Object?> get props => [key];
}

class EmployeeListInitial extends EmployeeListState{

}

class EmployeeListLoading extends EmployeeListState{

}

class EmployeeListLoaded extends EmployeeListState{
  List<Employee> employees;

  EmployeeListLoaded(this.employees);
  @override
  // TODO: implement props
  List<Object?> get props => [employees,key];
}

class NoEmployeeFound extends EmployeeListState{

}

