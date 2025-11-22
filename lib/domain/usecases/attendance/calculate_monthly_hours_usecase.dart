import '../../repositories/attendance_repository.dart';

class CalculateMonthlyHoursUseCase {
  final AttendanceRepository repository;

  CalculateMonthlyHoursUseCase(this.repository);

  Future<double> call(String employeeId) async {
    return await repository.calculateMonthlyHours(employeeId);
  }
}

