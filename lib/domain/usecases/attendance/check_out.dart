// check_out.dart
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/attendance_entity.dart';
import '../../repositories/attendance_repository.dart';

class CheckOut {
  final AttendanceRepository repository;

  CheckOut(this.repository);

  Future<Either<Failure, AttendanceEntity>> call(String attendanceId) async {
    return await repository.checkOut(attendanceId);
  }
}