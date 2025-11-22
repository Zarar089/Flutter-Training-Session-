import 'package:equatable/equatable.dart';
import '../../../domain/entities/employee_entity.dart';

abstract class EmployeeFormEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddEmployeeEvent extends EmployeeFormEvent {
  final EmployeeEntity employee;

  AddEmployeeEvent(this.employee);

  @override
  List<Object?> get props => [employee];
}

class UpdateEmployeeEvent extends EmployeeFormEvent {
  final EmployeeEntity employee;

  UpdateEmployeeEvent(this.employee);

  @override
  List<Object?> get props => [employee];
}