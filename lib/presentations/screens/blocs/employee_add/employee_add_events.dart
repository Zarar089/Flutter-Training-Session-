import 'package:equatable/equatable.dart';
import '../../../../domain/entities/employee.dart';

abstract class EmployeeAddEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class EmployeeAddSubmitTriggered extends EmployeeAddEvent {
  final Employee employee;
  final bool isUpdate;

  EmployeeAddSubmitTriggered(this.employee, {this.isUpdate = false});

  @override
  List<Object?> get props => [employee, isUpdate];
}
