import '../../repositories/attendance_repository.dart';

class CheckOutUseCase {
  final AttendanceRepository repository;

  CheckOutUseCase(this.repository);

  Future<void> call(String employeeId) async {
    return await repository.checkOut(employeeId);
  }
}

