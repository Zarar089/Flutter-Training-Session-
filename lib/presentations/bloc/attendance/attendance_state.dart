// attendance_state.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/attendance_entity.dart';

abstract class AttendanceState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final List<AttendanceEntity> attendance;

  AttendanceLoaded(this.attendance);

  @override
  List<Object?> get props => [attendance];
}

class MonthlyStatsLoaded extends AttendanceState {
  final Map<String, dynamic> stats;

  MonthlyStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class AttendanceError extends AttendanceState {
  final String message;

  AttendanceError(this.message);

  @override
  List<Object?> get props => [message];
}