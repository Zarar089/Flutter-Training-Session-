import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/local/realm_datasource.dart';
import '../datasources/remote/firebase_datasource.dart';
import '../datasources/local/realm_schemas/attendance_realm.dart';
import '../models/attendance_model.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final FirebaseDataSource firebaseDataSource;
  final RealmDataSource<AttendanceRealm> realmDataSource;

  AttendanceRepositoryImpl({
    required this.firebaseDataSource,
    required this.realmDataSource,
  });

  @override
  Future<Either<Failure, List<AttendanceEntity>>> getAttendance(
      String employeeId) async {
    try {
      final firebaseData = await firebaseDataSource.getAll();

      final attendanceList = firebaseData.entries
          .where((entry) {
            final data = Map<String, dynamic>.from(entry.value as Map);
            return data['employeeId'] == employeeId;
          })
          .map((entry) {
            final data = Map<String, dynamic>.from(entry.value as Map);
            data['id'] = entry.key;
            return AttendanceModel.fromJson(data);
          })
          .toList();

      // Sort by date descending
      attendanceList.sort((a, b) => b.date.compareTo(a.date));

      // Cache to Realm
      final realmAttendance = attendanceList
          .map((att) => AttendanceRealm(
                att.id,
                att.employeeId,
                att.employeeName,
                att.date,
                att.checkInTime,
                att.totalHours,
                att.status,
                checkOutTime: att.checkOutTime,
              ))
          .toList();

      realmDataSource.deleteAll();
      realmDataSource.insertAll(realmAttendance);

      return Right(attendanceList);
    } on ServerException catch (e) {
      // Fallback to Realm
      try {
        final realmAttendance = realmDataSource
            .getAll()
            .where((att) => att.employeeId == employeeId)
            .toList();

        final attendance = realmAttendance
            .map((att) => AttendanceEntity(
                  id: att.id,
                  employeeId: att.employeeId,
                  employeeName: att.employeeName,
                  date: att.date,
                  checkInTime: att.checkInTime,
                  checkOutTime: att.checkOutTime,
                  totalHours: att.totalHours,
                  status: att.status,
                ))
            .toList();

        return Right(attendance);
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }

  @override
  Future<Either<Failure, AttendanceEntity>> checkIn(
      String employeeId, String employeeName) async {
    try {
      final now = DateTime.now();
      final dateKey = DateFormat('yyyy-MM-dd').format(now);
      final attendanceId = '${employeeId}_$dateKey';

      // Check if already checked in today
      final existing = await firebaseDataSource.getById(attendanceId);
      if (existing != null && existing['checkOutTime'] == null) {
        return Left(ValidationFailure('Already checked in today'));
      }

      final attendanceData = {
        'employeeId': employeeId,
        'employeeName': employeeName,
        'date': now.toIso8601String(),
        'checkInTime': now.toIso8601String(),
        'checkOutTime': null,
        'totalHours': 0.0,
        'status': 'present',
      };

      await firebaseDataSource.insert(attendanceId, attendanceData);

      // Cache to Realm
      realmDataSource.insert(AttendanceRealm(
        attendanceId,
        employeeId,
        employeeName,
        now,
        now,
        0.0,
        'present',
      ));

      attendanceData['id'] = attendanceId;
      return Right(AttendanceModel.fromJson(attendanceData));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, AttendanceEntity>> checkOut(String attendanceId) async {
    try {
      final existing = await firebaseDataSource.getById(attendanceId);
      if (existing == null) {
        return Left(ValidationFailure('Check in first'));
      }

      if (existing['checkOutTime'] != null) {
        return Left(ValidationFailure('Already checked out today'));
      }

      final now = DateTime.now();
      final checkInTime = DateTime.parse(existing['checkInTime'] as String);
      final duration = now.difference(checkInTime);
      final totalHours = duration.inMinutes / 60;

      await firebaseDataSource.update(attendanceId, {
        'checkOutTime': now.toIso8601String(),
        'totalHours': totalHours,
      });

      existing['id'] = attendanceId;
      existing['checkOutTime'] = now.toIso8601String();
      existing['totalHours'] = totalHours;

      return Right(AttendanceModel.fromJson(existing));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMonthlyStats(
      String employeeId) async {
    try {
      final attendanceResult = await getAttendance(employeeId);

      return attendanceResult.fold(
        (failure) => Left(failure),
        (attendance) {
          final now = DateTime.now();
          final monthRecords = attendance.where((a) {
            return a.date.year == now.year && a.date.month == now.month;
          }).toList();

          final totalHours = monthRecords.fold(
              0.0, (sum, a) => sum + a.totalHours);
          final totalDays = monthRecords.length;

          return Right({
            'totalHours': totalHours,
            'totalDays': totalDays,
            'averageHours': totalDays > 0 ? totalHours / totalDays : 0.0,
          });
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to calculate monthly stats: $e'));
    }
  }
}