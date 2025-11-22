import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

abstract class EmployeeAddState extends Equatable {
  final Key key = UniqueKey();

  @override
  List<Object?> get props => [key];
}

class EmployeeAddInitial extends EmployeeAddState {}

class EmployeeAddSubmitting extends EmployeeAddState {}

class EmployeeAddSuccess extends EmployeeAddState {
  final String message;

  EmployeeAddSuccess(this.message);

  @override
  List<Object?> get props => [message, key];
}

class EmployeeAddError extends EmployeeAddState {
  final String message;

  EmployeeAddError(this.message);

  @override
  List<Object?> get props => [message, key];
}
