import '../entities/attendance.dart';

abstract class AttendanceRepository {
  Future<List<Attendance>> getAttendanceRecords();
  Future<List<Attendance>> getAttendanceByEmployeeId(String employeeId);
  Future<void> markCheckIn(String employeeId, String employeeName);
  Future<void> markCheckOut(String employeeId);
  Future<double> getMonthlyHours(String employeeId);
}

