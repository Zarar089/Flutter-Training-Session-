import 'package:employee_app_v1_spaghetti/domain/use_cases/employee_usecase.dart';
import 'package:employee_app_v1_spaghetti/presentations/screens/blocs/employee_list/employee_list_bloc.dart';
import 'package:employee_app_v1_spaghetti/presentations/screens/blocs/employee_list/employee_list_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/employee.dart';
import 'attendance_screen.dart';
import 'blocs/employee_list/employee_list_events.dart';
import 'employee_add_screen.dart';
import 'employee_detail_screen.dart';

// ⚠️ SPAGHETTI CODE - ALL LOGIC IN ONE FILE
// UI + Business Logic + Data Access all mixed together

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    // no direct data access here - bloc will fetch
  }

  void _searchEmployees(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  void _navigateToDetail(Employee employee) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeDetailScreen(employee: employee),
      ),
    );

    // If detail screen signals deletion, trigger refresh
    if (!mounted) return;
    if (result == true) {
      context.read<EmployeeListBloc>().add(EmployeeListFetchTriggered());
    }
  }

  void _navigateToAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EmployeeAddScreen(),
      ),
    ).then((_) {
      if (mounted) {
        context.read<EmployeeListBloc>().add(EmployeeListFetchTriggered());
      }
    });
  }

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
    return BlocProvider<EmployeeListBloc>(
      create: (context) =>
          EmployeeListBloc(employeeUseCase: EmployeeUseCase())
            ..add(EmployeeListFetchTriggered()),
      child: Builder(
        builder: (blocContext) => Scaffold(
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
                  blocContext
                      .read<EmployeeListBloc>()
                      .add(EmployeeListFetchTriggered());
                },
                tooltip: 'Refresh',
              ),
            ],
          ),
          body: BlocConsumer<EmployeeListBloc, EmployeeListState>(
            listener: (context, state) {
              if (state is EmployeeListError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(state.message)),
                );
              }
            },
            builder: (context, state) {
            final isLoading = state is EmployeeListInitial;
            final employees =
                state is EmployeeListLoaded ? state.employees : <Employee>[];

            // compute filteredEmployees from current state + searchQuery
            final filteredEmployees = searchQuery.isEmpty
                ? employees
                : employees.where((emp) {
                    final q = searchQuery.toLowerCase();
                    return emp.name.toLowerCase().contains(q) ||
                        emp.position.toLowerCase().contains(q) ||
                        emp.department.toLowerCase().contains(q);
                  }).toList();

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
                    onChanged: _searchEmployees,
                  ),
                ),

                // Employee list / states
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
                                        employee.name
                                            .toString()[0]
                                            .toUpperCase(),
                                      ),
                                    ),
                                    title: Text(
                                      employee.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                        '${employee.position} - ${employee.department}'),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () =>
                                          _showDeleteDialog(blocContext, employee.id),
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
        ),
          floatingActionButton: FloatingActionButton(
            onPressed: _navigateToAdd,
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String id) {
    // Capture the bloc reference before showing the dialog
    final bloc = context.read<EmployeeListBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Employee'),
        content: const Text('Are you sure you want to delete this employee?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Dispatch fetch to refresh after deletion. Ideally you'd dispatch a Delete event to the bloc that calls the use case.
              // For now, we assume deletion happens elsewhere (detail/edit) and we refresh list.
              bloc.add(EmployeeListFetchTriggered());
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
    super.dispose();
  }
}
