// get_attendance.dart
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/attendance_entity.dart';
import '../../repositories/attendance_repository.dart';

class GetAttendance {
  final AttendanceRepository repository;

  GetAttendance(this.repository);

  Future<Either<Failure, List<AttendanceEntity>>> call(String employeeId) async {
    return await repository.getAttendance(employeeId);
  }
}