import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../presentation/bloc/employee/employee_bloc.dart';
import '../presentation/bloc/employee/employee_event.dart';
import '../presentation/bloc/employee/employee_state.dart';
import '../domain/entities/employee.dart';
import 'employee_detail_screen.dart';
import 'employee_add_screen.dart';
import 'attendance_screen.dart';

class EmployeeListScreen extends StatelessWidget {
  const EmployeeListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        actions: [
          IconButton(
            icon: const Icon(Icons.access_time),
            onPressed: () => _navigateToAttendance(context),
            tooltip: 'Attendance',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshEmployees(context),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocConsumer<EmployeeBloc, EmployeeState>(
        listener: (context, state) {
          if (state is EmployeeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is EmployeeOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is EmployeeLoaded && state.errorMessage != null) {
            // Show warning banner for offline mode
          }
        },
        builder: (context, state) {
          if (state is EmployeeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is EmployeeError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _loadEmployees(context),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is EmployeeLoaded) {
            final employees = state.filteredEmployees;
            final errorMessage = state.errorMessage;

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
                    onChanged: (query) => _searchEmployees(context, query),
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
                  child: employees.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No employees found',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: employees.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context, index) {
                            final employee = employees[index];
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
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  '${employee.position} - ${employee.department}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _showDeleteDialog(context, employee.id),
                                ),
                                onTap: () => _navigateToDetail(context, employee),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }

          // Initial state
          return const Center(
            child: Text('Loading employees...'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAdd(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _loadEmployees(BuildContext context) {
    context.read<EmployeeBloc>().add(const LoadEmployees());
  }

  void _refreshEmployees(BuildContext context) {
    context.read<EmployeeBloc>().add(const RefreshEmployees());
  }

  void _searchEmployees(BuildContext context, String query) {
    context.read<EmployeeBloc>().add(SearchEmployees(query));
  }

  void _navigateToDetail(BuildContext context, Employee employee) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeDetailScreen(employee: employee),
      ),
    );
    // BLoC will automatically refresh when operations complete
  }

  void _navigateToAdd(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EmployeeAddScreen(),
      ),
    );
    // BLoC will automatically refresh when operations complete
  }

  void _navigateToAttendance(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AttendanceScreen(),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String id) {
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
              context.read<EmployeeBloc>().add(DeleteEmployee(id));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
