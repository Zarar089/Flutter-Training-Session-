import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/attendance/get_attendance_records_usecase.dart';
import '../../../domain/usecases/attendance/check_in_usecase.dart';
import '../../../domain/usecases/attendance/check_out_usecase.dart';
import '../../../domain/usecases/attendance/calculate_monthly_hours_usecase.dart';
import '../../../domain/usecases/employee/get_employees_usecase.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final GetAttendanceRecordsUseCase getAttendanceRecordsUseCase;
  final CheckInUseCase checkInUseCase;
  final CheckOutUseCase checkOutUseCase;
  final CalculateMonthlyHoursUseCase calculateMonthlyHoursUseCase;
  final GetEmployeesUseCase getEmployeesUseCase;

  AttendanceBloc({
    required this.getAttendanceRecordsUseCase,
    required this.checkInUseCase,
    required this.checkOutUseCase,
    required this.calculateMonthlyHoursUseCase,
    required this.getEmployeesUseCase,
  }) : super(const AttendanceInitial()) {
    on<LoadAttendance>(_onLoadAttendance);
    on<LoadEmployees>(_onLoadEmployees);
    on<SelectEmployee>(_onSelectEmployee);
    on<CheckIn>(_onCheckIn);
    on<CheckOut>(_onCheckOut);
    on<RefreshAttendance>(_onRefreshAttendance);
    on<CalculateMonthlyHours>(_onCalculateMonthlyHours);
  }

  Future<void> _onLoadAttendance(
    LoadAttendance event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(const AttendanceLoading());

    try {
      final records = await getAttendanceRecordsUseCase();
      emit(AttendanceLoaded(
        attendanceRecords: records,
        employees: state is AttendanceLoaded ? (state as AttendanceLoaded).employees : [],
        selectedEmployeeId: state is AttendanceLoaded ? (state as AttendanceLoaded).selectedEmployeeId : null,
      ));

      // Calculate monthly hours if employee is selected
      if (state is AttendanceLoaded) {
        final currentState = state as AttendanceLoaded;
        if (currentState.selectedEmployeeId != null) {
          add(CalculateMonthlyHours(currentState.selectedEmployeeId!));
        }
      }
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> _onLoadEmployees(
    LoadEmployees event,
    Emitter<AttendanceState> emit,
  ) async {
    try {
      final employees = await getEmployeesUseCase();

      if (state is AttendanceLoaded) {
        final currentState = state as AttendanceLoaded;
        String? selectedId = currentState.selectedEmployeeId;
        
        if (selectedId == null && employees.isNotEmpty) {
          selectedId = employees.first.id;
        }

        emit(currentState.copyWith(
          employees: employees,
          selectedEmployeeId: selectedId,
        ));

        // Load attendance if not loaded yet
        if (currentState.attendanceRecords.isEmpty) {
          add(const LoadAttendance());
        } else if (selectedId != null) {
          add(CalculateMonthlyHours(selectedId));
        }
      } else {
        emit(AttendanceLoaded(
          attendanceRecords: [],
          employees: employees,
          selectedEmployeeId: employees.isNotEmpty ? employees.first.id : null,
        ));
        add(const LoadAttendance());
      }
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> _onSelectEmployee(
    SelectEmployee event,
    Emitter<AttendanceState> emit,
  ) async {
    if (state is AttendanceLoaded) {
      final currentState = state as AttendanceLoaded;
      emit(currentState.copyWith(selectedEmployeeId: event.employeeId));
      add(CalculateMonthlyHours(event.employeeId));
      add(const LoadAttendance());
    }
  }

  Future<void> _onCheckIn(
    CheckIn event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(const AttendanceOperationLoading());

    try {
      await checkInUseCase(event.employeeId, event.employeeName);
      emit(const AttendanceOperationSuccess('Checked in successfully'));

      // Reload attendance
      add(const LoadAttendance());
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> _onCheckOut(
    CheckOut event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(const AttendanceOperationLoading());

    try {
      await checkOutUseCase(event.employeeId);
      emit(const AttendanceOperationSuccess('Checked out successfully'));

      // Reload attendance
      add(const LoadAttendance());
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
      emit(currentState.copyWith(errorMessage: null));
    }

    try {
      final records = await getAttendanceRecordsUseCase();

      if (state is AttendanceLoaded) {
        final currentState = state as AttendanceLoaded;
        emit(currentState.copyWith(attendanceRecords: records));

        if (currentState.selectedEmployeeId != null) {
          add(CalculateMonthlyHours(currentState.selectedEmployeeId!));
        }
      } else {
        emit(AttendanceLoaded(
          attendanceRecords: records,
          employees: [],
        ));
      }
    } catch (e) {
      if (state is AttendanceLoaded) {
        final currentState = state as AttendanceLoaded;
        emit(currentState.copyWith(errorMessage: 'Error refreshing: ${e.toString()}'));
      } else {
        emit(AttendanceError(e.toString()));
      }
    }
  }

  Future<void> _onCalculateMonthlyHours(
    CalculateMonthlyHours event,
    Emitter<AttendanceState> emit,
  ) async {
    if (state is AttendanceLoaded) {
      try {
        final hours = await calculateMonthlyHoursUseCase(event.employeeId);
        final currentState = state as AttendanceLoaded;
        emit(currentState.copyWith(monthlyHours: hours));
      } catch (e) {
        // Silently fail - don't break the UI
        if (state is AttendanceLoaded) {
          final currentState = state as AttendanceLoaded;
          emit(currentState.copyWith(monthlyHours: 0.0));
        }
      }
    }
  }
}

