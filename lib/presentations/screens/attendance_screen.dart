import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:realm/realm.dart';

import '../../attendance_model.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final DatabaseReference _attendanceRef =
      FirebaseDatabase.instance.ref('attendance');
  final DatabaseReference _employeesRef =
      FirebaseDatabase.instance.ref('employees');
  Realm? _realm;

  List<Map<String, dynamic>> attendanceRecords = [];
  List<Map<String, dynamic>> employees = [];
  bool isLoading = false;
  String? selectedEmployeeId;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initRealm();
    _loadEmployees();
    _loadAttendance();
  }

  void _initRealm() {
    // Realm doesn't support web, so only initialize on non-web platforms
    if (!kIsWeb) {
      try {
        final config = Configuration.local([Attendance.schema]);
        _realm = Realm(config);
      } catch (e) {
        debugPrint('Realm initialization failed: $e');
      }
    }
  }

  Future<void> _loadEmployees() async {
    try {
      final snapshot = await _employeesRef.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        employees = data.entries.map((entry) {
          final value = entry.value as Map<dynamic, dynamic>;
          return {
            'id': entry.key as String,
            'name': value['name'] as String,
          };
        }).toList();

        if (employees.isNotEmpty && selectedEmployeeId == null) {
          setState(() => selectedEmployeeId = employees.first['id']);
        }
      }
    } catch (e) {
      debugPrint('Error loading employees: $e');
    }
  }

  Future<void> _loadAttendance() async {
    setState(() => isLoading = true);

    try {
      final snapshot = await _attendanceRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        attendanceRecords = data.entries.map((entry) {
          final value = entry.value as Map<dynamic, dynamic>;
          return {
            'id': entry.key as String,
            'employeeId': value['employeeId'] as String,
            'employeeName': value['employeeName'] as String,
            'date': DateTime.parse(value['date'] as String),
            'checkInTime': DateTime.parse(value['checkInTime'] as String),
            'checkOutTime': value['checkOutTime'] != null
                ? DateTime.parse(value['checkOutTime'] as String)
                : null,
            'totalHours': (value['totalHours'] as num?)?.toDouble() ?? 0.0,
            'status': value['status'] as String,
          };
        }).toList();

        // Sort by date descending
        attendanceRecords.sort((a, b) => b['date'].compareTo(a['date']));

        // Cache to Realm (if available, not on web)
        if (_realm != null) {
          _realm!.write(() {
            _realm!.deleteAll<Attendance>();
            for (var record in attendanceRecords) {
              _realm!.add(Attendance(
                record['id'],
                record['employeeId'],
                record['employeeName'],
                record['date'],
                record['checkInTime'],
                record['totalHours'],
                record['status'],
                checkOutTime: record['checkOutTime'],
              ));
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Firebase error: $e, loading from cache');
      // Try to load from Realm cache if available
      if (_realm != null) {
        try {
          final realmData = _realm!.all<Attendance>();
          attendanceRecords = realmData
              .map((record) => {
                    'id': record.id,
                    'employeeId': record.employeeId,
                    'employeeName': record.employeeName,
                    'date': record.date,
                    'checkInTime': record.checkInTime,
                    'checkOutTime': record.checkOutTime,
                    'totalHours': record.totalHours,
                    'status': record.status,
                  })
              .toList();
        } catch (realmError) {
          debugPrint('Error loading from Realm: $realmError');
          attendanceRecords = [];
        }
      } else {
        // On web or if Realm is not available, keep empty list
        attendanceRecords = [];
      }
    }

    setState(() => isLoading = false);
  }

  Future<void> _markCheckIn() async {
    if (selectedEmployeeId == null) return;

    final employee = employees.firstWhere((e) => e['id'] == selectedEmployeeId);
    final now = DateTime.now();
    final dateKey = DateFormat('yyyy-MM-dd').format(now);
    final attendanceId = '${selectedEmployeeId}_$dateKey';

    // Check if already checked in today
    final existingRecord = attendanceRecords.firstWhere(
      (r) => r['id'] == attendanceId,
      orElse: () => {},
    );

    if (existingRecord.isNotEmpty && existingRecord['checkOutTime'] == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Already checked in today')),
      );
      return;
    }

    try {
      final attendanceData = {
        'employeeId': selectedEmployeeId,
        'employeeName': employee['name'],
        'date': now.toIso8601String(),
        'checkInTime': now.toIso8601String(),
        'checkOutTime': null,
        'totalHours': 0.0,
        'status': 'present',
      };

      await _attendanceRef.child(attendanceId).set(attendanceData);

      // Save to Realm (if available, not on web)
      if (_realm != null) {
        _realm!.write(() {
          _realm!.add(
              Attendance(
                attendanceId,
                selectedEmployeeId!,
                employee['name'],
                now,
                now,
                0.0,
                'present',
              ),
              update: true);
        });
      }

      _loadAttendance();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checked in successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _markCheckOut() async {
    if (selectedEmployeeId == null) return;

    final now = DateTime.now();
    final dateKey = DateFormat('yyyy-MM-dd').format(now);
    final attendanceId = '${selectedEmployeeId}_$dateKey';

    final existingRecord = attendanceRecords.firstWhere(
      (r) => r['id'] == attendanceId,
      orElse: () => {},
    );

    if (existingRecord.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please check in first')),
      );
      return;
    }

    if (existingRecord['checkOutTime'] != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Already checked out today')),
      );
      return;
    }

    try {
      final checkInTime = existingRecord['checkInTime'] as DateTime;
      final duration = now.difference(checkInTime);
      final totalHours = duration.inMinutes / 60;

      await _attendanceRef.child(attendanceId).update({
        'checkOutTime': now.toIso8601String(),
        'totalHours': totalHours,
      });

      _loadAttendance();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Checked out - Total: ${totalHours.toStringAsFixed(2)} hours')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  double _calculateMonthlyHours() {
    if (selectedEmployeeId == null) return 0.0;

    final now = DateTime.now();
    final monthRecords = attendanceRecords.where((r) {
      final date = r['date'] as DateTime;
      return r['employeeId'] == selectedEmployeeId &&
          date.year == now.year &&
          date.month == now.month;
    });

    return monthRecords.fold(
        0.0, (sum, r) => sum + (r['totalHours'] as double));
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('hh:mm a');
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAttendance,
          ),
        ],
      ),
      body: Column(
        children: [
          // Employee Selector
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedEmployeeId,
                  decoration: const InputDecoration(
                    labelText: 'Select Employee',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: employees.map((emp) {
                    return DropdownMenuItem<String>(
                      value: emp['id'],
                      child: Text(emp['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedEmployeeId = value);
                    _loadAttendance();
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _markCheckIn,
                        icon: const Icon(Icons.login),
                        label: const Text('Check In'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _markCheckOut,
                        icon: const Icon(Icons.logout),
                        label: const Text('Check Out'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Monthly Stats
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('This Month', style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      '${_calculateMonthlyHours().toStringAsFixed(1)} hrs',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text('Total Days', style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      '${attendanceRecords.where((r) => r['employeeId'] == selectedEmployeeId).length}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Attendance History
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: attendanceRecords
                        .where((r) => r['employeeId'] == selectedEmployeeId)
                        .length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final records = attendanceRecords
                          .where((r) => r['employeeId'] == selectedEmployeeId)
                          .toList();

                      if (index >= records.length) return const SizedBox();

                      final record = records[index];
                      final checkOut = record['checkOutTime'];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                checkOut != null ? Colors.green : Colors.orange,
                            child: Icon(
                              checkOut != null ? Icons.check : Icons.timer,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(dateFormat.format(record['date'])),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'In: ${timeFormat.format(record['checkInTime'])}'),
                              if (checkOut != null)
                                Text('Out: ${timeFormat.format(checkOut)}'),
                            ],
                          ),
                          trailing: checkOut != null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${record['totalHours'].toStringAsFixed(1)} hrs',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                )
                              : const Chip(
                                  label: Text('Active',
                                      style: TextStyle(fontSize: 12)),
                                  backgroundColor: Colors.orange,
                                ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _realm?.close();
    super.dispose();
  }
}
