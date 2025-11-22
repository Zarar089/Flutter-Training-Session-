import 'package:equatable/equatable.dart';
import '../../domain/entities/attendance.dart';

abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final List<Attendance> records;
  final String? selectedEmployeeId;
  final double monthlyHours;

  const AttendanceLoaded(
    this.records, {
    this.selectedEmployeeId,
    this.monthlyHours = 0.0,
  });

  @override
  List<Object?> get props => [records, selectedEmployeeId, monthlyHours];
}

class AttendanceError extends AttendanceState {
  final String message;

  const AttendanceError(this.message);

  @override
  List<Object?> get props => [message];
}

class AttendanceOperationSuccess extends AttendanceState {
  final String message;

  const AttendanceOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

