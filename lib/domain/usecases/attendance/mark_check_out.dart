import '../../repositories/attendance_repository.dart';

class MarkCheckOut {
  final AttendanceRepository repository;

  MarkCheckOut(this.repository);

  Future<void> call(String employeeId) async {
    return await repository.markCheckOut(employeeId);
  }
}

