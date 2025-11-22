import '../../entities/attendance.dart';
import '../../repositories/attendance_repository.dart';

class GetAttendanceRecordsUseCase {
  final AttendanceRepository repository;

  GetAttendanceRecordsUseCase(this.repository);

  Future<List<Attendance>> call() async {
    return await repository.getAttendanceRecords();
  }
}

