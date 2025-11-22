// check_in.dart
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/attendance_entity.dart';
import '../../repositories/attendance_repository.dart';

class CheckIn {
  final AttendanceRepository repository;

  CheckIn(this.repository);

  Future<Either<Failure, AttendanceEntity>> call(String employeeId, String employeeName) async {
    return await repository.checkIn(employeeId, employeeName);
  }
}