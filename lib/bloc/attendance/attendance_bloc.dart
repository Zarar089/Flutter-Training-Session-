import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/attendance/get_attendance_by_employee_id.dart';
import '../../domain/usecases/attendance/get_attendance_records.dart';
import '../../domain/usecases/attendance/get_monthly_hours.dart';
import '../../domain/usecases/attendance/mark_check_in.dart' as mark_check_in_uc;
import '../../domain/usecases/attendance/mark_check_out.dart' as mark_check_out_uc;
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final GetAttendanceRecords getAttendanceRecords;
  final GetAttendanceByEmployeeId getAttendanceByEmployeeId;
  final mark_check_in_uc.MarkCheckIn markCheckIn;
  final mark_check_out_uc.MarkCheckOut markCheckOut;
  final GetMonthlyHours getMonthlyHours;

  AttendanceBloc({
    required this.getAttendanceRecords,
    required this.getAttendanceByEmployeeId,
    required this.markCheckIn,
    required this.markCheckOut,
    required this.getMonthlyHours,
  }) : super(AttendanceInitial()) {
    on<LoadAttendanceRecords>(_onLoadAttendanceRecords);
    on<LoadAttendanceByEmployee>(_onLoadAttendanceByEmployee);
    on<MarkCheckIn>(_onMarkCheckIn);
    on<MarkCheckOut>(_onMarkCheckOut);
    on<LoadMonthlyHours>(_onLoadMonthlyHours);
    on<RefreshAttendance>(_onRefreshAttendance);
  }

  Future<void> _onLoadAttendanceRecords(
    LoadAttendanceRecords event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      final records = await getAttendanceRecords();
      emit(AttendanceLoaded(records));
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> _onLoadAttendanceByEmployee(
    LoadAttendanceByEmployee event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      final records = await getAttendanceByEmployeeId(event.employeeId);
      final monthlyHours = await getMonthlyHours(event.employeeId);
      emit(AttendanceLoaded(
        records,
        selectedEmployeeId: event.employeeId,
        monthlyHours: monthlyHours,
      ));
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> _onMarkCheckIn(
    MarkCheckIn event,
    Emitter<AttendanceState> emit,
  ) async {
    try {
      await markCheckIn(event.employeeId, event.employeeName);
      emit(const AttendanceOperationSuccess('Checked in successfully'));
      add(LoadAttendanceByEmployee(event.employeeId));
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> _onMarkCheckOut(
    MarkCheckOut event,
    Emitter<AttendanceState> emit,
  ) async {
    try {
      await markCheckOut(event.employeeId);
      emit(const AttendanceOperationSuccess('Checked out successfully'));
      add(LoadAttendanceByEmployee(event.employeeId));
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> _onLoadMonthlyHours(
    LoadMonthlyHours event,
    Emitter<AttendanceState> emit,
  ) async {
    try {
      final hours = await getMonthlyHours(event.employeeId);
      if (state is AttendanceLoaded) {
        final currentState = state as AttendanceLoaded;
        emit(AttendanceLoaded(
          currentState.records,
          selectedEmployeeId: currentState.selectedEmployeeId,
          monthlyHours: hours,
        ));
      }
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> _onRefreshAttendance(
    RefreshAttendance event,
    Emitter<AttendanceState> emit,
  ) async {
    if (state is AttendanceLoaded) {
      final currentState = state as AttendanceLoaded;
      if (currentState.selectedEmployeeId != null) {
        add(LoadAttendanceByEmployee(currentState.selectedEmployeeId!));
      } else {
        add(const LoadAttendanceRecords());
      }
    } else {
      add(const LoadAttendanceRecords());
    }
  }
}

