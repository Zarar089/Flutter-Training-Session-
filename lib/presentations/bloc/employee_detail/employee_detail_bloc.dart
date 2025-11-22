import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/employee/delete_employee.dart';
import 'employee_detail_event.dart';
import 'employee_detail_state.dart';

class EmployeeDetailBloc extends Bloc<EmployeeDetailEvent, EmployeeDetailState> {
  final DeleteEmployee deleteEmployee;

  EmployeeDetailBloc({
    required this.deleteEmployee,
  }) : super(EmployeeDetailInitial()) {
    on<DeleteEmployeeDetailEvent>(_onDeleteEmployee);
  }

  Future<void> _onDeleteEmployee(
    DeleteEmployeeDetailEvent event,
    Emitter<EmployeeDetailState> emit,
  ) async {
    emit(EmployeeDetailLoading());
    
    final result = await deleteEmployee(event.employeeId);
    
    result.fold(
      (failure) => emit(EmployeeDetailError(failure.message)),
      (_) => emit(EmployeeDetailDeleted()),
    );
  }
}