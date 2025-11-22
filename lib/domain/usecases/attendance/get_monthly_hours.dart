import '../../repositories/attendance_repository.dart';

class GetMonthlyHours {
  final AttendanceRepository repository;

  GetMonthlyHours(this.repository);

  Future<double> call(String employeeId) async {
    return await repository.getMonthlyHours(employeeId);
  }
}

