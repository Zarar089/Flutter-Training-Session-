import 'package:employee_app_v1_spaghetti/domain/use_cases/employee_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'employee_list_events.dart';
import 'employee_list_state.dart';

class EmployeeListBloc extends Bloc<EmployeeListEvents, EmployeeListState> {
  final EmployeeUseCase employeeUseCase;

  EmployeeListBloc({required this.employeeUseCase})
      : super(EmployeeListInitial()) {
    on<EmployeeListFetchTriggered>(_fetchEmployeeList);
    employeeUseCase.init();
  }

  Future<void> _fetchEmployeeList(
      EmployeeListFetchTriggered event, Emitter<EmployeeListState> emit) async {
    emit(EmployeeListInitial());
    try {
      final employees = await employeeUseCase.fetchEmployeeData();
      emit(EmployeeListLoaded(employees));
    } catch (e) {
      emit(EmployeeListError(e.toString()));
    }
  }
}
