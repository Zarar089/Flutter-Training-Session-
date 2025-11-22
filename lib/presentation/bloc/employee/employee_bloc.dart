import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/employee/get_employees_usecase.dart';
import '../../../domain/usecases/employee/add_employee_usecase.dart';
import '../../../domain/usecases/employee/update_employee_usecase.dart';
import '../../../domain/usecases/employee/delete_employee_usecase.dart';
import '../../../domain/usecases/employee/search_employees_usecase.dart';
import 'employee_event.dart';
import 'employee_state.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final GetEmployeesUseCase getEmployeesUseCase;
  final AddEmployeeUseCase addEmployeeUseCase;
  final UpdateEmployeeUseCase updateEmployeeUseCase;
  final DeleteEmployeeUseCase deleteEmployeeUseCase;
  final SearchEmployeesUseCase searchEmployeesUseCase;

  EmployeeBloc({
    required this.getEmployeesUseCase,
    required this.addEmployeeUseCase,
    required this.updateEmployeeUseCase,
    required this.deleteEmployeeUseCase,
    required this.searchEmployeesUseCase,
  }) : super(const EmployeeInitial()) {
    on<LoadEmployees>(_onLoadEmployees);
    on<RefreshEmployees>(_onRefreshEmployees);
    on<SearchEmployees>(_onSearchEmployees);
    on<AddEmployee>(_onAddEmployee);
    on<UpdateEmployee>(_onUpdateEmployee);
    on<DeleteEmployee>(_onDeleteEmployee);
  }

  Future<void> _onLoadEmployees(
    LoadEmployees event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(const EmployeeLoading());

    try {
      final employees = await getEmployeesUseCase();
      emit(EmployeeLoaded(
        employees: employees,
        filteredEmployees: employees,
      ));
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }

  Future<void> _onRefreshEmployees(
    RefreshEmployees event,
    Emitter<EmployeeState> emit,
  ) async {
    if (state is EmployeeLoaded) {
      final currentState = state as EmployeeLoaded;
      emit(currentState.copyWith(errorMessage: null));
    }

    try {
      final employees = await getEmployeesUseCase();
      
      if (state is EmployeeLoaded) {
        final currentState = state as EmployeeLoaded;
        final searchQuery = currentState.employees.length != currentState.filteredEmployees.length
            ? _getSearchQuery(currentState)
            : '';
        
        if (searchQuery.isNotEmpty) {
          final filtered = await searchEmployeesUseCase(searchQuery);
          emit(EmployeeLoaded(
            employees: employees,
            filteredEmployees: filtered,
          ));
        } else {
          emit(EmployeeLoaded(
            employees: employees,
            filteredEmployees: employees,
          ));
        }
      } else {
        emit(EmployeeLoaded(
          employees: employees,
          filteredEmployees: employees,
        ));
      }
    } catch (e) {
      if (state is EmployeeLoaded) {
        final currentState = state as EmployeeLoaded;
        emit(currentState.copyWith(errorMessage: 'Error refreshing: ${e.toString()}'));
      } else {
        emit(EmployeeError(e.toString()));
      }
    }
  }

  String _getSearchQuery(EmployeeLoaded state) {
    // Simple heuristic: if filtered list is different, there was a search
    // In a real app, we'd store the query in state
    return '';
  }

  Future<void> _onSearchEmployees(
    SearchEmployees event,
    Emitter<EmployeeState> emit,
  ) async {
    if (state is EmployeeLoaded) {
      final currentState = state as EmployeeLoaded;

      try {
        final filtered = await searchEmployeesUseCase(event.query);
        emit(currentState.copyWith(filteredEmployees: filtered));
      } catch (e) {
        emit(EmployeeError(e.toString()));
      }
    }
  }

  Future<void> _onAddEmployee(
    AddEmployee event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(const EmployeeOperationLoading());

    try {
      await addEmployeeUseCase(event.employee);
      emit(const EmployeeOperationSuccess('Employee added successfully'));

      // Reload employees
      final employees = await getEmployeesUseCase();
      emit(EmployeeLoaded(
        employees: employees,
        filteredEmployees: employees,
      ));
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }

  Future<void> _onUpdateEmployee(
    UpdateEmployee event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(const EmployeeOperationLoading());

    try {
      await updateEmployeeUseCase(event.employee);
      emit(const EmployeeOperationSuccess('Employee updated successfully'));

      // Reload employees
      final employees = await getEmployeesUseCase();
      emit(EmployeeLoaded(
        employees: employees,
        filteredEmployees: employees,
      ));
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }

  Future<void> _onDeleteEmployee(
    DeleteEmployee event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(const EmployeeOperationLoading());

    try {
      await deleteEmployeeUseCase(event.id);
      emit(const EmployeeOperationSuccess('Employee deleted successfully'));

      // Reload employees
      final employees = await getEmployeesUseCase();
      
      if (state is EmployeeLoaded) {
        final currentState = state as EmployeeLoaded;
        final searchQuery = currentState.employees.length != currentState.filteredEmployees.length
            ? _getSearchQuery(currentState)
            : '';
        
        if (searchQuery.isNotEmpty) {
          final filtered = await searchEmployeesUseCase(searchQuery);
          emit(EmployeeLoaded(
            employees: employees,
            filteredEmployees: filtered,
          ));
        } else {
          emit(EmployeeLoaded(
            employees: employees,
            filteredEmployees: employees,
          ));
        }
      } else {
        emit(EmployeeLoaded(
          employees: employees,
          filteredEmployees: employees,
        ));
      }
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }
}

