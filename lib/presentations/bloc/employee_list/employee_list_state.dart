import 'package:equatable/equatable.dart';
import '../../../domain/entities/employee_entity.dart';

abstract class EmployeeListState extends Equatable {
  @override
  List<Object?> get props => [];
}

class EmployeeListInitial extends EmployeeListState {}

class EmployeeListLoading extends EmployeeListState {}

class EmployeeListLoaded extends EmployeeListState {
  final List<EmployeeEntity> employees;

  EmployeeListLoaded(this.employees);

  @override
  List<Object?> get props => [employees];
}

class EmployeeListError extends EmployeeListState {
  final String message;

  EmployeeListError(this.message);

  @override
  List<Object?> get props => [message];
}