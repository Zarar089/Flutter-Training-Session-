import 'package:employee_app_v1_spaghetti/domain/use_cases/employee_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'employee_add_events.dart';
import 'employee_add_state.dart';

class EmployeeAddBloc extends Bloc<EmployeeAddEvent, EmployeeAddState> {
  final EmployeeUseCase _employeeUseCase;

  EmployeeAddBloc(this._employeeUseCase) : super(EmployeeAddInitial()) {
    on<EmployeeAddSubmitTriggered>(_onSubmitEmployee);
  }

  Future<void> _onSubmitEmployee(
    EmployeeAddSubmitTriggered event,
    Emitter<EmployeeAddState> emit,
  ) async {
    emit(EmployeeAddSubmitting());

    try {
      if (event.isUpdate) {
        await _employeeUseCase.updateEmployee(event.employee);
        emit(EmployeeAddSuccess('Employee updated successfully'));
      } else {
        await _employeeUseCase.addEmployee(event.employee);
        emit(EmployeeAddSuccess('Employee added successfully'));
      }
    } catch (e) {
      emit(EmployeeAddError(e.toString()));
    }
  }
}
