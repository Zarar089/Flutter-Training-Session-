import 'package:employee_app_v1_spaghetti/domain/use_cases/employee_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'employee_detail_events.dart';
import 'employee_detail_state.dart';

class EmployeeDetailBloc
    extends Bloc<EmployeeDetailEvent, EmployeeDetailState> {
  final EmployeeUseCase _employeeUseCase;

  EmployeeDetailBloc(this._employeeUseCase) : super(EmployeeDetailInitial()) {
    on<EmployeeDetailLoadTriggered>(_onLoadEmployee);
    on<EmployeeDetailDeleteTriggered>(_onDeleteEmployee);
  }

  Future<void> _onLoadEmployee(
    EmployeeDetailLoadTriggered event,
    Emitter<EmployeeDetailState> emit,
  ) async {
    emit(EmployeeDetailLoading());

    try {
      final employee = await _employeeUseCase.getEmployeeById(event.employeeId);

      if (employee != null) {
        emit(EmployeeDetailLoaded(employee));
      } else {
        emit(EmployeeDetailError('Employee not found'));
      }
    } catch (e) {
      emit(EmployeeDetailError(e.toString()));
    }
  }

  Future<void> _onDeleteEmployee(
    EmployeeDetailDeleteTriggered event,
    Emitter<EmployeeDetailState> emit,
  ) async {
    emit(EmployeeDetailDeleting());

    try {
      await _employeeUseCase.deleteEmployee(event.employeeId);
      emit(EmployeeDetailDeleted());
    } catch (e) {
      emit(EmployeeDetailError(e.toString()));
    }
  }
}
