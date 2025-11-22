import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/employee/add_employee.dart' as add_employee_uc;
import '../../domain/usecases/employee/delete_employee.dart' as delete_employee_uc;
import '../../domain/usecases/employee/get_employees.dart';
import '../../domain/usecases/employee/search_employees.dart' as search_employees_uc;
import '../../domain/usecases/employee/update_employee.dart' as update_employee_uc;
import 'employee_event.dart';
import 'employee_state.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final GetEmployees getEmployees;
  final search_employees_uc.SearchEmployees searchEmployees;
  final add_employee_uc.AddEmployee addEmployee;
  final update_employee_uc.UpdateEmployee updateEmployee;
  final delete_employee_uc.DeleteEmployee deleteEmployee;

  EmployeeBloc({
    required this.getEmployees,
    required this.searchEmployees,
    required this.addEmployee,
    required this.updateEmployee,
    required this.deleteEmployee,
  }) : super(EmployeeInitial()) {
    on<LoadEmployees>(_onLoadEmployees);
    on<SearchEmployees>(_onSearchEmployees);
    on<AddEmployee>(_onAddEmployee);
    on<UpdateEmployee>(_onUpdateEmployee);
    on<DeleteEmployee>(_onDeleteEmployee);
    on<RefreshEmployees>(_onRefreshEmployees);
  }

  Future<void> _onLoadEmployees(
    LoadEmployees event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(EmployeeLoading());
    try {
      final employees = await getEmployees();
      emit(EmployeeLoaded(employees));
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }

  Future<void> _onSearchEmployees(
    SearchEmployees event,
    Emitter<EmployeeState> emit,
  ) async {
    if (event.query.isEmpty) {
      add(const LoadEmployees());
      return;
    }

    emit(EmployeeLoading());
    try {
      final employees = await searchEmployees(event.query);
      emit(EmployeeLoaded(employees, searchQuery: event.query));
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }

  Future<void> _onAddEmployee(
    AddEmployee event,
    Emitter<EmployeeState> emit,
  ) async {
    try {
      await addEmployee(event.employee);
      emit(const EmployeeOperationSuccess('Employee added successfully'));
      add(const LoadEmployees());
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }

  Future<void> _onUpdateEmployee(
    UpdateEmployee event,
    Emitter<EmployeeState> emit,
  ) async {
    try {
      await updateEmployee(event.employee);
      emit(const EmployeeOperationSuccess('Employee updated successfully'));
      add(const LoadEmployees());
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }

  Future<void> _onDeleteEmployee(
    DeleteEmployee event,
    Emitter<EmployeeState> emit,
  ) async {
    try {
      await deleteEmployee(event.id);
      emit(const EmployeeOperationSuccess('Employee deleted successfully'));
      add(const LoadEmployees());
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }

  Future<void> _onRefreshEmployees(
    RefreshEmployees event,
    Emitter<EmployeeState> emit,
  ) async {
    add(const LoadEmployees());
  }
}

