import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/employee/get_employees.dart';
import '../../../domain/usecases/employee/search_employees.dart';
import '../../../domain/usecases/employee/delete_employee.dart';
import 'employee_list_event.dart';
import 'employee_list_state.dart';

class EmployeeListBloc extends Bloc<EmployeeListEvent, EmployeeListState> {
  final GetEmployees getEmployees;
  final SearchEmployees searchEmployees;
  final DeleteEmployee deleteEmployee;

  EmployeeListBloc({
    required this.getEmployees,
    required this.searchEmployees,
    required this.deleteEmployee,
  }) : super(EmployeeListInitial()) {
    on<FetchEmployeesEvent>(_onFetchEmployees);
    on<SearchEmployeesEvent>(_onSearchEmployees);
    on<DeleteEmployeeEvent>(_onDeleteEmployee);
  }

  Future<void> _onFetchEmployees(
    FetchEmployeesEvent event,
    Emitter<EmployeeListState> emit,
  ) async {
    emit(EmployeeListLoading());
    
    final result = await getEmployees();
    
    result.fold(
      (failure) => emit(EmployeeListError(failure.message)),
      (employees) => emit(EmployeeListLoaded(employees)),
    );
  }

  Future<void> _onSearchEmployees(
    SearchEmployeesEvent event,
    Emitter<EmployeeListState> emit,
  ) async {
    emit(EmployeeListLoading());
    
    if (event.query.isEmpty) {
      add(FetchEmployeesEvent());
      return;
    }
    
    final result = await searchEmployees(event.query);
    
    result.fold(
      (failure) => emit(EmployeeListError(failure.message)),
      (employees) => emit(EmployeeListLoaded(employees)),
    );
  }

  Future<void> _onDeleteEmployee(
    DeleteEmployeeEvent event,
    Emitter<EmployeeListState> emit,
  ) async {
    final currentState = state;
    if (currentState is EmployeeListLoaded) {
      emit(EmployeeListLoading());
      
      final result = await deleteEmployee(event.employeeId);
      
      result.fold(
        (failure) => emit(EmployeeListError(failure.message)),
        (_) => add(FetchEmployeesEvent()),
      );
    }
  }
}