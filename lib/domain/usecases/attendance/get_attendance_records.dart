import '../../entities/attendance.dart';
import '../../repositories/attendance_repository.dart';

class GetAttendanceRecords {
  final AttendanceRepository repository;

  GetAttendanceRecords(this.repository);

  Future<List<Attendance>> call() async {
    return await repository.getAttendanceRecords();
  }
}

