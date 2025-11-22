import '../entities/attendance.dart';

abstract class AttendanceRepository {
  Future<List<Attendance>> getAttendanceRecords();
  Future<List<Attendance>> getAttendanceByEmployeeId(String employeeId);
  Future<Attendance?> getTodayAttendance(String employeeId);
  Future<void> checkIn(String employeeId, String employeeName);
  Future<void> checkOut(String employeeId);
  Future<double> calculateMonthlyHours(String employeeId);
}

