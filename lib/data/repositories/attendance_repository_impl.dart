import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:realm/realm.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../mappers/attendance_mapper.dart';
import '../models/reals_models/attendence/attendance_model.dart' as realm_model;

class AttendanceRepositoryImpl implements AttendanceRepository {
  final DatabaseReference _attendanceRef;
  final DatabaseReference _employeesRef;
  final Realm _realm;

  AttendanceRepositoryImpl(this._attendanceRef, this._employeesRef, this._realm);

  @override
  Future<List<Attendance>> getAttendanceRecords() async {
    try {
      final snapshot = await _attendanceRef.get();
      List<Attendance> records = [];

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        records = data.entries.map((entry) {
          return AttendanceMapper.fromMap(
            entry.key as String,
            entry.value as Map<dynamic, dynamic>,
          );
        }).toList();

        // Sort by date descending
        records.sort((a, b) => b.date.compareTo(a.date));

        // Cache to Realm
        _realm.write(() {
          _realm.deleteAll<realm_model.Attendance>();
          for (var record in records) {
            _realm.add(AttendanceMapper.toRealm(record), update: true);
          }
        });
      } else {
        // Load from Realm if Firebase is empty
        final realmData = _realm.all<realm_model.Attendance>();
        records = realmData.map((r) => AttendanceMapper.fromRealm(r)).toList();
        records.sort((a, b) => b.date.compareTo(a.date));
      }

      return records;
    } catch (e) {
      // Fallback to Realm on error
      final realmData = _realm.all<realm_model.Attendance>();
      final records = realmData.map((r) => AttendanceMapper.fromRealm(r)).toList();
      records.sort((a, b) => b.date.compareTo(a.date));
      return records;
    }
  }

  @override
  Future<List<Attendance>> getAttendanceByEmployeeId(String employeeId) async {
    final allRecords = await getAttendanceRecords();
    return allRecords.where((r) => r.employeeId == employeeId).toList();
  }

  @override
  Future<void> markCheckIn(String employeeId, String employeeName) async {
    final now = DateTime.now();
    final dateKey = DateFormat('yyyy-MM-dd').format(now);
    final attendanceId = '${employeeId}_$dateKey';

    // Check if already checked in today
    final existingRecords = await getAttendanceByEmployeeId(employeeId);
    final todayRecord = existingRecords.firstWhere(
      (r) => r.id == attendanceId,
      orElse: () => Attendance(
        id: '',
        employeeId: '',
        employeeName: '',
        date: DateTime.now(),
        checkInTime: DateTime.now(),
        totalHours: 0.0,
        status: '',
      ),
    );

    if (todayRecord.id.isNotEmpty && todayRecord.checkOutTime == null) {
      throw Exception('Already checked in today');
    }

    final attendance = Attendance(
      id: attendanceId,
      employeeId: employeeId,
      employeeName: employeeName,
      date: now,
      checkInTime: now,
      checkOutTime: null,
      totalHours: 0.0,
      status: 'present',
    );

    try {
      // Save to Firebase
      await _attendanceRef.child(attendanceId).set(AttendanceMapper.toMap(attendance));

      // Save to Realm
      _realm.write(() {
        _realm.add(AttendanceMapper.toRealm(attendance), update: true);
      });
    } catch (e) {
      // Still save to Realm even if Firebase fails
      _realm.write(() {
        _realm.add(AttendanceMapper.toRealm(attendance), update: true);
      });
      rethrow;
    }
  }

  @override
  Future<void> markCheckOut(String employeeId) async {
    final now = DateTime.now();
    final dateKey = DateFormat('yyyy-MM-dd').format(now);
    final attendanceId = '${employeeId}_$dateKey';

    final existingRecords = await getAttendanceByEmployeeId(employeeId);
    final todayRecord = existingRecords.firstWhere(
      (r) => r.id == attendanceId,
      orElse: () => Attendance(
        id: '',
        employeeId: '',
        employeeName: '',
        date: DateTime.now(),
        checkInTime: DateTime.now(),
        totalHours: 0.0,
        status: '',
      ),
    );

    if (todayRecord.id.isEmpty) {
      throw Exception('Please check in first');
    }

    if (todayRecord.checkOutTime != null) {
      throw Exception('Already checked out today');
    }

    final duration = now.difference(todayRecord.checkInTime);
    final totalHours = duration.inMinutes / 60.0;

    try {
      // Update Firebase
      await _attendanceRef.child(attendanceId).update({
        'checkOutTime': now.toIso8601String(),
        'totalHours': totalHours,
      });

      // Update Realm
      final updatedAttendance = Attendance(
        id: todayRecord.id,
        employeeId: todayRecord.employeeId,
        employeeName: todayRecord.employeeName,
        date: todayRecord.date,
        checkInTime: todayRecord.checkInTime,
        checkOutTime: now,
        totalHours: totalHours,
        status: todayRecord.status,
      );

      _realm.write(() {
        _realm.add(AttendanceMapper.toRealm(updatedAttendance), update: true);
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<double> getMonthlyHours(String employeeId) async {
    final records = await getAttendanceByEmployeeId(employeeId);
    final now = DateTime.now();
    
    final monthRecords = records.where((r) {
      return r.date.year == now.year && r.date.month == now.month;
    });

    double total = 0.0;
    for (var record in monthRecords) {
      total += record.totalHours;
    }
    return total;
  }
}

