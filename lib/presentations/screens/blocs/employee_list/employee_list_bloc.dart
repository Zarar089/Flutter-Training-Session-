import 'package:employee_app_v1_spaghetti/domain/use_cases/employee_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'employee_list_events.dart';
import 'employee_list_state.dart';

class EmployeeListBloc extends Bloc<EmployeeListEvents, EmployeeListState> {
  final EmployeeUseCase _employeeUseCase;

  EmployeeListBloc(this._employeeUseCase) : super(EmployeeListInitial()) {
    on<EmployeeListFetchTriggered>(_fetchEmployeeList);
    on<EmployeeListDeleteTriggered>(_deleteEmployee);
  }

  Future<void> _fetchEmployeeList(
    EmployeeListFetchTriggered event,
    Emitter<EmployeeListState> emit,
  ) async {
    emit(EmployeeListLoading());

    try {
      final employees = await _employeeUseCase.fetchEmployeeData();

      if (employees.isEmpty) {
        emit(NoEmployeeFound());
      } else {
        emit(EmployeeListLoaded(employees));
      }
    } catch (e) {
      emit(EmployeeListError(e.toString()));
    }
  }

  Future<void> _deleteEmployee(
    EmployeeListDeleteTriggered event,
    Emitter<EmployeeListState> emit,
  ) async {
    try {
      await _employeeUseCase.deleteEmployee(event.employeeId);
      // Refresh the list after deletion
      add(EmployeeListFetchTriggered());
    } catch (e) {
      emit(EmployeeListError(e.toString()));
    }
  }
}
