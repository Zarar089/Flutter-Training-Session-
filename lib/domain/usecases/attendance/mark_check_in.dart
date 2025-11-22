import '../../repositories/attendance_repository.dart';

class MarkCheckIn {
  final AttendanceRepository repository;

  MarkCheckIn(this.repository);

  Future<void> call(String employeeId, String employeeName) async {
    return await repository.markCheckIn(employeeId, employeeName);
  }
}

