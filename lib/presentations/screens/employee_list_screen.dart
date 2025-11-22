import 'package:employee_app_v1_spaghetti/core/di/dependency_injection.dart';
import 'package:employee_app_v1_spaghetti/presentations/screens/blocs/employee_list/employee_list_bloc.dart';
import 'package:employee_app_v1_spaghetti/presentations/screens/blocs/employee_list/employee_list_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/employee.dart';
import 'attendance_screen.dart';
import 'blocs/employee_list/employee_list_events.dart';
import 'employee_add_screen.dart';
import 'employee_detail_screen.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  late final EmployeeListBloc employeeListBloc;

  // State management with setState
  List<Employee> filteredEmployees = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    employeeListBloc = getIt<EmployeeListBloc>();
  }

  // Search functionality - business logic in UI
  void _searchEmployees(String query, List<Employee> employees) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredEmployees = employees;
      } else {
        filteredEmployees = employees.where((emp) {
          return emp.name.toLowerCase().contains(query.toLowerCase()) ||
              emp.position.toLowerCase().contains(query.toLowerCase()) ||
              emp.department.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  // Delete employee - Using BLoC
  Future<void> _deleteEmployee(String id) async {
    employeeListBloc.add(EmployeeListDeleteTriggered(id));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Employee deleted successfully')),
      );
    }
  }

  // Navigate to detail screen
  void _navigateToDetail(Employee employee) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeDetailScreen(employee: employee),
      ),
    ).then((_) => employeeListBloc.add(EmployeeListFetchTriggered()));
  }

  // Navigate to add screen
  void _navigateToAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EmployeeAddScreen(),
      ),
    ).then((_) => employeeListBloc.add(EmployeeListFetchTriggered()));
  }

  // Navigate to attendance screen
  void _navigateToAttendance() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AttendanceScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        actions: [
          IconButton(
            icon: const Icon(Icons.access_time),
            onPressed: _navigateToAttendance,
            tooltip: 'Attendance',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              employeeListBloc.add(EmployeeListFetchTriggered());
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocProvider<EmployeeListBloc>(
        create: (context) =>
            employeeListBloc..add(EmployeeListFetchTriggered()),
        child: BlocConsumer<EmployeeListBloc, EmployeeListState>(
          builder: (context, state) {
            List<Employee> employees = [];
            bool isLoading = false;
            String? errorMessage;

            if (state is EmployeeListLoading) {
              isLoading = true;
            } else if (state is EmployeeListLoaded) {
              employees = state.employees;
              // Update filtered employees when data is loaded and no active search
              if (searchQuery.isEmpty) {
                filteredEmployees = employees;
              }
            } else if (state is EmployeeListError) {
              errorMessage = state.message;
            } else if (state is NoEmployeeFound) {
              employees = [];
              filteredEmployees = [];
            }

            return Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search employees...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (query) => _searchEmployees(query, employees),
                  ),
                ),

                // Error message banner
                if (errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.orange.shade100,
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(child: Text(errorMessage)),
                      ],
                    ),
                  ),

                // Employee list
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredEmployees.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.people_outline,
                                      size: 64, color: Colors.grey.shade400),
                                  const SizedBox(height: 16),
                                  Text(
                                    searchQuery.isEmpty
                                        ? 'No employees found'
                                        : 'No matching employees',
                                    style:
                                        TextStyle(color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredEmployees.length,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemBuilder: (context, index) {
                                final employee = filteredEmployees[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      child: Text(
                                        employee.name[0].toUpperCase(),
                                      ),
                                    ),
                                    title: Text(
                                      employee.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      '${employee.position} - ${employee.department}',
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () =>
                                          _showDeleteDialog(employee.id),
                                    ),
                                    onTap: () => _navigateToDetail(employee),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            );
          },
          listener: (context, state) {
            if (state is EmployeeListLoaded) {
              if (searchQuery.isEmpty) {
                setState(() {
                  filteredEmployees = state.employees;
                });
              }
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAdd,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: const Text('Are you sure you want to delete this employee?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEmployee(id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    employeeListBloc.close();
    super.dispose();
  }
}
