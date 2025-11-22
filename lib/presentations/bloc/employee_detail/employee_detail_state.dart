import 'package:equatable/equatable.dart';

abstract class EmployeeDetailState extends Equatable {
  @override
  List<Object?> get props => [];
}

class EmployeeDetailInitial extends EmployeeDetailState {}

class EmployeeDetailLoading extends EmployeeDetailState {}

class EmployeeDetailDeleted extends EmployeeDetailState {}

class EmployeeDetailError extends EmployeeDetailState {
  final String message;

  EmployeeDetailError(this.message);

  @override
  List<Object?> get props => [message];
}