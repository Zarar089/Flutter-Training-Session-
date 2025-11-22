import 'package:equatable/equatable.dart';
import '../../../domain/entities/attendance.dart';
import '../../../domain/entities/employee.dart';

abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object> get props => [];
}

class AttendanceInitial extends AttendanceState {
  const AttendanceInitial();
}

class AttendanceLoading extends AttendanceState {
  const AttendanceLoading();
}

class AttendanceLoaded extends AttendanceState {
  final List<Attendance> attendanceRecords;
  final List<Employee> employees;
  final String? selectedEmployeeId;
  final double monthlyHours;
  final String? errorMessage;

  const AttendanceLoaded({
    required this.attendanceRecords,
    required this.employees,
    this.selectedEmployeeId,
    this.monthlyHours = 0.0,
    this.errorMessage,
  });

  AttendanceLoaded copyWith({
    List<Attendance>? attendanceRecords,
    List<Employee>? employees,
    String? selectedEmployeeId,
    double? monthlyHours,
    String? errorMessage,
  }) {
    return AttendanceLoaded(
      attendanceRecords: attendanceRecords ?? this.attendanceRecords,
      employees: employees ?? this.employees,
      selectedEmployeeId: selectedEmployeeId ?? this.selectedEmployeeId,
      monthlyHours: monthlyHours ?? this.monthlyHours,
      errorMessage: errorMessage,
    );
  }

  List<Attendance> get filteredRecords {
    if (selectedEmployeeId == null) return [];
    return attendanceRecords.where((r) => r.employeeId == selectedEmployeeId).toList();
  }

  @override
  List<Object> get props => [attendanceRecords, employees, selectedEmployeeId ?? '', monthlyHours, errorMessage ?? ''];
}

class AttendanceError extends AttendanceState {
  final String message;

  const AttendanceError(this.message);

  @override
  List<Object> get props => [message];
}

class AttendanceOperationLoading extends AttendanceState {
  const AttendanceOperationLoading();
}

class AttendanceOperationSuccess extends AttendanceState {
  final String message;

  const AttendanceOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

