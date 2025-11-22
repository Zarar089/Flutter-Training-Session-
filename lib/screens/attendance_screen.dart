import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../presentation/bloc/attendance/attendance_bloc.dart';
import '../presentation/bloc/attendance/attendance_event.dart';
import '../presentation/bloc/attendance/attendance_state.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      body: BlocConsumer<AttendanceBloc, AttendanceState>(
        listener: (context, state) {
          if (state is AttendanceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is AttendanceOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is AttendanceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AttendanceError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AttendanceBloc>().add(const LoadAttendance());
                      context.read<AttendanceBloc>().add(const LoadEmployees());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is AttendanceLoaded) {
            final employees = state.employees;
            final selectedEmployeeId = state.selectedEmployeeId;
            final records = state.filteredRecords;
            final monthlyHours = state.monthlyHours;

            if (employees.isEmpty) {
              return const Center(
                child: Text('No employees found. Please add employees first.'),
              );
            }

            final selectedEmployee = employees.firstWhere(
              (e) => e.id == selectedEmployeeId,
              orElse: () => employees.first,
            );

            return Column(
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
                        onChanged: (value) {
                          if (value != null) {
                            context.read<AttendanceBloc>().add(SelectEmployee(value));
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                context.read<AttendanceBloc>().add(
                                      CheckIn(selectedEmployee.id, selectedEmployee.name),
                                    );
                              },
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
                              onPressed: () {
                                if (selectedEmployeeId != null) {
                                  context.read<AttendanceBloc>().add(
                                        CheckOut(selectedEmployeeId),
                                      );
                                }
                              },
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
                            '${monthlyHours.toStringAsFixed(1)} hrs',
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
                            '${records.length}',
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

                // Error message banner
                if (state.errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.orange.shade100,
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(child: Text(state.errorMessage!)),
                      ],
                    ),
                  ),

                // Attendance History
                Expanded(
                  child: BlocBuilder<AttendanceBloc, AttendanceState>(
                    builder: (context, state) {
                      if (state is AttendanceOperationLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is AttendanceLoaded) {
                        final filteredRecords = state.filteredRecords;

                        if (filteredRecords.isEmpty) {
                          return const Center(
                            child: Text('No attendance records found'),
                          );
                        }

                        return ListView.builder(
                          itemCount: filteredRecords.length,
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (context, index) {
                            final record = filteredRecords[index];
                            final checkOut = record.checkOutTime;
                            final timeFormat = DateFormat('hh:mm a');
                            final dateFormat = DateFormat('MMM dd, yyyy');

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

                      return const Center(child: Text('No data'));
                    },
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text('Loading...'));
        },
      ),
    );
  }
}
