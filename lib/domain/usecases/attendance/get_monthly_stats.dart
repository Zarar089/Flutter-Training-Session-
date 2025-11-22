// get_monthly_stats.dart
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/attendance_repository.dart';

class GetMonthlyStats {
  final AttendanceRepository repository;

  GetMonthlyStats(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String employeeId) async {
    return await repository.getMonthlyStats(employeeId);
  }
}