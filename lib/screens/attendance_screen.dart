import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/attendance/attendance_bloc.dart';
import '../bloc/attendance/attendance_event.dart';
import '../bloc/attendance/attendance_state.dart';
import '../domain/entities/attendance.dart';
import '../domain/entities/employee.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String? selectedEmployeeId;
  List<Employee> employees = [];

  @override
  void initState() {
    super.initState();
    _loadEmployees();
    context.read<AttendanceBloc>().add(const LoadAttendanceRecords());
  }

  Future<void> _loadEmployees() async {
    try {
      final snapshot = await FirebaseDatabase.instance.ref('employees').get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          employees = data.entries.map((entry) {
            final value = entry.value as Map<dynamic, dynamic>;
            return Employee(
              id: entry.key as String,
              name: value['name'] as String,
              email: value['email'] as String,
              position: value['position'] as String,
              department: value['department'] as String,
              joinDate: DateTime.parse(value['joinDate'] as String),
              phone: value['phone'] as String,
              salary: (value['salary'] as num).toDouble(),
            );
          }).toList();

          if (employees.isNotEmpty && selectedEmployeeId == null) {
            selectedEmployeeId = employees.first.id;
            context.read<AttendanceBloc>().add(
                  LoadAttendanceByEmployee(selectedEmployeeId!),
                );
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading employees: $e');
    }
  }

  void _onEmployeeSelected(String? employeeId) {
    if (employeeId != null) {
      setState(() => selectedEmployeeId = employeeId);
      context.read<AttendanceBloc>().add(LoadAttendanceByEmployee(employeeId));
    }
  }

  void _markCheckIn() {
    if (selectedEmployeeId == null) return;

    final employee = employees.firstWhere((e) => e.id == selectedEmployeeId);
    context.read<AttendanceBloc>().add(
          MarkCheckIn(selectedEmployeeId!, employee.name),
        );
  }

  void _markCheckOut() {
    if (selectedEmployeeId == null) return;

    context.read<AttendanceBloc>().add(MarkCheckOut(selectedEmployeeId!));
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
            onPressed: () {
              context.read<AttendanceBloc>().add(const RefreshAttendance());
            },
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
                  value: selectedEmployeeId,
                  decoration: const InputDecoration(
                    labelText: 'Select Employee',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: employees.map((emp) {
                    return DropdownMenuItem<String>(
                      value: emp.id,
                      child: Text(emp.name),
                    );
                  }).toList(),
                  onChanged: _onEmployeeSelected,
                ),
                const SizedBox(height: 16),
                BlocBuilder<AttendanceBloc, AttendanceState>(
                  builder: (context, state) {
                    final isLoading = state is AttendanceLoading;
                    final canCheckIn = selectedEmployeeId != null && !isLoading;
                    final canCheckOut = selectedEmployeeId != null && !isLoading;

                    // Check if already checked in today
                    bool alreadyCheckedIn = false;
                    bool alreadyCheckedOut = false;
                    if (state is AttendanceLoaded && selectedEmployeeId != null) {
                      final now = DateTime.now();
                      final todayRecord = state.records.firstWhere(
                        (r) =>
                            r.employeeId == selectedEmployeeId &&
                            r.date.year == now.year &&
                            r.date.month == now.month &&
                            r.date.day == now.day,
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
                      alreadyCheckedIn = todayRecord.id.isNotEmpty;
                      alreadyCheckedOut = todayRecord.checkOutTime != null;
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: canCheckIn && !alreadyCheckedIn ? _markCheckIn : null,
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
                            onPressed: canCheckOut && alreadyCheckedIn && !alreadyCheckedOut
                                ? _markCheckOut
                                : null,
                            icon: const Icon(Icons.logout),
                            label: const Text('Check Out'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // Monthly Stats
          BlocBuilder<AttendanceBloc, AttendanceState>(
            builder: (context, state) {
              if (state is AttendanceLoaded) {
                final totalDays = state.records.length;
                return Container(
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
                            '${state.monthlyHours.toStringAsFixed(1)} hrs',
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
                            '$totalDays',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Attendance History
          Expanded(
            child: BlocBuilder<AttendanceBloc, AttendanceState>(
              builder: (context, state) {
                if (state is AttendanceLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is AttendanceError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (selectedEmployeeId != null) {
                              context.read<AttendanceBloc>().add(
                                    LoadAttendanceByEmployee(selectedEmployeeId!),
                                  );
                            } else {
                              context.read<AttendanceBloc>().add(const LoadAttendanceRecords());
                            }
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is AttendanceLoaded) {
                  final records = state.records;

                  if (records.isEmpty) {
                    return const Center(
                      child: Text('No attendance records found'),
                    );
                  }

                  return ListView.builder(
                    itemCount: records.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final record = records[index];
                      final checkOut = record.checkOutTime;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: checkOut != null ? Colors.green : Colors.orange,
                            child: Icon(
                              checkOut != null ? Icons.check : Icons.timer,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(dateFormat.format(record.date)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('In: ${timeFormat.format(record.checkInTime)}'),
                              if (checkOut != null)
                                Text('Out: ${timeFormat.format(checkOut)}'),
                            ],
                          ),
                          trailing: checkOut != null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${record.totalHours.toStringAsFixed(1)} hrs',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                )
                              : const Chip(
                                  label: Text('Active', style: TextStyle(fontSize: 12)),
                                  backgroundColor: Colors.orange,
                                ),
                        ),
                      );
                    },
                  );
                }

                return const Center(
                  child: Text('No data available'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
