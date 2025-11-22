import 'package:equatable/equatable.dart';

abstract class EmployeeFormState extends Equatable {
  @override
  List<Object?> get props => [];
}

class EmployeeFormInitial extends EmployeeFormState {}

class EmployeeFormLoading extends EmployeeFormState {}

class EmployeeFormSuccess extends EmployeeFormState {}

class EmployeeFormError extends EmployeeFormState {
  final String message;

  EmployeeFormError(this.message);

  @override
  List<Object?> get props => [message];
}