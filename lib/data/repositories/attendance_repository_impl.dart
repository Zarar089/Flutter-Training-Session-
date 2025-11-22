import '../../domain/entities/attendance.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../data_source/local_data_source/realm_db.dart';
import '../mappers/attendance_mapper.dart';
import '../../attendance_model.dart' as realm_model;
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final DatabaseReference attendanceRef;
  final RealmDataSource<realm_model.Attendance> realmDataSource;

  AttendanceRepositoryImpl({
    required this.attendanceRef,
    required this.realmDataSource,
  });

  @override
  Future<List<Attendance>> getAttendanceRecords() async {
    try {
      // Try Firebase first
      final snapshot = await attendanceRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final records = data.entries.map((entry) {
          final value = entry.value as Map<dynamic, dynamic>;
          return AttendanceMapper.fromMap(
            entry.key as String,
            {
              'employeeId': value['employeeId'] as String,
              'employeeName': value['employeeName'] as String,
              'date': value['date'] as String,
              'checkInTime': value['checkInTime'] as String,
              'checkOutTime': value['checkOutTime'] as String?,
              'totalHours': (value['totalHours'] as num?)?.toDouble() ?? 0.0,
              'status': value['status'] as String,
            },
          );
        }).toList();

        // Sort by date descending
        records.sort((a, b) => b.date.compareTo(a.date));

        // Cache to Realm
        realmDataSource.realm.write(() {
          realmDataSource.realm.deleteAll<realm_model.Attendance>();
          for (var record in records) {
            realmDataSource.insert(AttendanceMapper.toRealm(record));
          }
        });

        return records;
      } else {
        return _loadFromRealm();
      }
    } catch (e) {
      // Fallback to Realm if Firebase fails
      return _loadFromRealm();
    }
  }

  List<Attendance> _loadFromRealm() {
    final realmData = realmDataSource.getAll();
    return realmData
        .map((record) => AttendanceMapper.fromRealm(record))
        .toList();
  }

  @override
  Future<List<Attendance>> getAttendanceByEmployeeId(String employeeId) async {
    final allRecords = await getAttendanceRecords();
    return allRecords.where((r) => r.employeeId == employeeId).toList();
  }

  @override
  Future<Attendance?> getTodayAttendance(String employeeId) async {
    final now = DateTime.now();
    final dateKey = DateFormat('yyyy-MM-dd').format(now);
    final attendanceId = '${employeeId}_$dateKey';

    try {
      final snapshot = await attendanceRef.child(attendanceId).get();
      if (snapshot.exists) {
        final value = snapshot.value as Map<dynamic, dynamic>;
        return AttendanceMapper.fromMap(
          attendanceId,
          {
            'employeeId': value['employeeId'] as String,
            'employeeName': value['employeeName'] as String,
            'date': value['date'] as String,
            'checkInTime': value['checkInTime'] as String,
            'checkOutTime': value['checkOutTime'] as String?,
            'totalHours': (value['totalHours'] as num?)?.toDouble() ?? 0.0,
            'status': value['status'] as String,
          },
        );
      }
    } catch (e) {
      // Fallback to Realm
    }

    final realmRecord = realmDataSource.findById(attendanceId);
    return realmRecord != null ? AttendanceMapper.fromRealm(realmRecord) : null;
  }

  @override
  Future<void> checkIn(String employeeId, String employeeName) async {
    final now = DateTime.now();
    final dateKey = DateFormat('yyyy-MM-dd').format(now);
    final attendanceId = '${employeeId}_$dateKey';

    // Check if already checked in today
    final existingRecord = await getTodayAttendance(employeeId);
    if (existingRecord != null && existingRecord.checkOutTime == null) {
      throw Exception('Already checked in today');
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

    try {
      await attendanceRef.child(attendanceId).set(attendanceData);

      realmDataSource.insert(AttendanceMapper.toRealm(Attendance(
        id: attendanceId,
        employeeId: employeeId,
        employeeName: employeeName,
        date: now,
        checkInTime: now,
        totalHours: 0.0,
        status: 'present',
      )));
    } catch (e) {
      // Still save to Realm even if Firebase fails
      realmDataSource.insert(AttendanceMapper.toRealm(Attendance(
        id: attendanceId,
        employeeId: employeeId,
        employeeName: employeeName,
        date: now,
        checkInTime: now,
        totalHours: 0.0,
        status: 'present',
      )));
      rethrow;
    }
  }

  @override
  Future<void> checkOut(String employeeId) async {
    final now = DateTime.now();
    final dateKey = DateFormat('yyyy-MM-dd').format(now);
    final attendanceId = '${employeeId}_$dateKey';

    final existingRecord = await getTodayAttendance(employeeId);
    if (existingRecord == null) {
      throw Exception('Please check in first');
    }

    if (existingRecord.checkOutTime != null) {
      throw Exception('Already checked out today');
    }

    final checkInTime = existingRecord.checkInTime;
    final duration = now.difference(checkInTime);
    final totalHours = duration.inMinutes / 60.0;

    try {
      await attendanceRef.child(attendanceId).update({
        'checkOutTime': now.toIso8601String(),
        'totalHours': totalHours,
      });

      // Update Realm
      final realmRecord = realmDataSource.findById(attendanceId);
      if (realmRecord != null) {
        realmDataSource.realm.write(() {
          realmRecord.checkOutTime = now;
          realmRecord.totalHours = totalHours;
        });
      }
    } catch (e) {
      // Still update Realm even if Firebase fails
      final realmRecord = realmDataSource.findById(attendanceId);
      if (realmRecord != null) {
        realmDataSource.realm.write(() {
          realmRecord.checkOutTime = now;
          realmRecord.totalHours = totalHours;
        });
      }
      rethrow;
    }
  }

  @override
  Future<double> calculateMonthlyHours(String employeeId) async {
    final records = await getAttendanceByEmployeeId(employeeId);
    final now = DateTime.now();

    final monthRecords = records.where((r) {
      return r.date.year == now.year && r.date.month == now.month;
    });

    return monthRecords.fold<double>(0.0, (sum, r) => sum + r.totalHours);
  }
}
