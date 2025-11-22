import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/attendance_entity.dart';

abstract class AttendanceRepository {
  Future<Either<Failure, List<AttendanceEntity>>> getAttendance(String employeeId);
  Future<Either<Failure, AttendanceEntity>> checkIn(String employeeId, String employeeName);
  Future<Either<Failure, AttendanceEntity>> checkOut(String attendanceId);
  Future<Either<Failure, Map<String, dynamic>>> getMonthlyStats(String employeeId);
}