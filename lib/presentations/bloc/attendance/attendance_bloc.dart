// attendance_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/attendance/get_attendance.dart';
import '../../../domain/usecases/attendance/check_in.dart';
import '../../../domain/usecases/attendance/check_out.dart';
import '../../../domain/usecases/attendance/get_monthly_stats.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final GetAttendance getAttendance;
  final CheckIn checkIn;
  final CheckOut checkOut;
  final GetMonthlyStats getMonthlyStats;

  AttendanceBloc({
    required this.getAttendance,
    required this.checkIn,
    required this.checkOut,
    required this.getMonthlyStats,
  }) : super(AttendanceInitial()) {
    on<FetchAttendanceEvent>(_onFetchAttendance);
    on<CheckInEvent>(_onCheckIn);
    on<CheckOutEvent>(_onCheckOut);
    on<FetchMonthlyStatsEvent>(_onFetchMonthlyStats);
  }

  Future<void> _onFetchAttendance(
    FetchAttendanceEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    
    final result = await getAttendance(event.employeeId);
    
    result.fold(
      (failure) => emit(AttendanceError(failure.message)),
      (attendance) => emit(AttendanceLoaded(attendance)),
    );
  }

  Future<void> _onCheckIn(
    CheckInEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    final result = await checkIn(event.employeeId, event.employeeName);
    
    result.fold(
      (failure) => emit(AttendanceError(failure.message)),
      (_) => add(FetchAttendanceEvent(event.employeeId)),
    );
  }

  Future<void> _onCheckOut(
    CheckOutEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    final result = await checkOut(event.attendanceId);
    
    result.fold(
      (failure) => emit(AttendanceError(failure.message)),
      (_) => add(FetchAttendanceEvent(event.employeeId)),
    );
  }

  Future<void> _onFetchMonthlyStats(
    FetchMonthlyStatsEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    final result = await getMonthlyStats(event.employeeId);
    
    result.fold(
      (failure) => emit(AttendanceError(failure.message)),
      (stats) => emit(MonthlyStatsLoaded(stats)),
    );
  }
}