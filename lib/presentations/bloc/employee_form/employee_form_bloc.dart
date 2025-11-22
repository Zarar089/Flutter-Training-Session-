import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/employee/add_employee.dart';
import '../../../domain/usecases/employee/update_employee.dart';
import 'employee_form_event.dart';
import 'employee_form_state.dart';

class EmployeeFormBloc extends Bloc<EmployeeFormEvent, EmployeeFormState> {
  final AddEmployee addEmployee;
  final UpdateEmployee updateEmployee;

  EmployeeFormBloc({
    required this.addEmployee,
    required this.updateEmployee,
  }) : super(EmployeeFormInitial()) {
    on<AddEmployeeEvent>(_onAddEmployee);
    on<UpdateEmployeeEvent>(_onUpdateEmployee);
  }

  Future<void> _onAddEmployee(
    AddEmployeeEvent event,
    Emitter<EmployeeFormState> emit,
  ) async {
    emit(EmployeeFormLoading());
    
    final result = await addEmployee(event.employee);
    
    result.fold(
      (failure) => emit(EmployeeFormError(failure.message)),
      (_) => emit(EmployeeFormSuccess()),
    );
  }

  Future<void> _onUpdateEmployee(
    UpdateEmployeeEvent event,
    Emitter<EmployeeFormState> emit,
  ) async {
    emit(EmployeeFormLoading());
    
    final result = await updateEmployee(event.employee);
    
    result.fold(
      (failure) => emit(EmployeeFormError(failure.message)),
      (_) => emit(EmployeeFormSuccess()),
    );
  }
}