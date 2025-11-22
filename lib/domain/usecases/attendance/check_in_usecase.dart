import '../../repositories/attendance_repository.dart';

class CheckInUseCase {
  final AttendanceRepository repository;

  CheckInUseCase(this.repository);

  Future<void> call(String employeeId, String employeeName) async {
    return await repository.checkIn(employeeId, employeeName);
  }
}

