import '../../entities/attendance.dart';
import '../../repositories/attendance_repository.dart';

class GetAttendanceByEmployeeId {
  final AttendanceRepository repository;

  GetAttendanceByEmployeeId(this.repository);

  Future<List<Attendance>> call(String employeeId) async {
    return await repository.getAttendanceByEmployeeId(employeeId);
  }
}

