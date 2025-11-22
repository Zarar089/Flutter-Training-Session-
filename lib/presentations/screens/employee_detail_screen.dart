import 'package:employee_app_v1_spaghetti/core/di/dependency_injection.dart';
import 'package:employee_app_v1_spaghetti/presentations/screens/blocs/employee_detail/employee_detail_bloc.dart';
import 'package:employee_app_v1_spaghetti/presentations/screens/blocs/employee_detail/employee_detail_events.dart';
import 'package:employee_app_v1_spaghetti/presentations/screens/blocs/employee_detail/employee_detail_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/employee.dart';
import 'employee_add_screen.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final Employee employee;

  const EmployeeDetailScreen({Key? key, required this.employee})
      : super(key: key);

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  late final EmployeeDetailBloc employeeDetailBloc;

  @override
  void initState() {
    super.initState();
    employeeDetailBloc = getIt<EmployeeDetailBloc>();
    employeeDetailBloc.add(EmployeeDetailLoadTriggered(widget.employee.id));
  }

  // Navigate to edit screen
  void _navigateToEdit(Employee employee) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeAddScreen(employee: employee),
      ),
    ).then((updated) {
      if (updated == true) {
        employeeDetailBloc.add(EmployeeDetailLoadTriggered(widget.employee.id));
      }
    });
  }

  // Calculate years of service
  int _calculateYearsOfService(Employee employee) {
    final joinDate = employee.joinDate;
    final now = DateTime.now();
    return now.year - joinDate.year;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return BlocProvider(
      create: (context) => employeeDetailBloc,
      child: BlocConsumer<EmployeeDetailBloc, EmployeeDetailState>(
        listener: (context, state) {
          if (state is EmployeeDetailDeleted) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Employee deleted successfully')),
            );
          } else if (state is EmployeeDetailError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          Employee? employee;
          bool isLoading = false;

          if (state is EmployeeDetailLoading ||
              state is EmployeeDetailDeleting) {
            isLoading = true;
          } else if (state is EmployeeDetailLoaded) {
            employee = state.employee;
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Employee Details'),
              actions: [
                if (employee != null) ...[
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _navigateToEdit(employee!),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _showDeleteDialog(employee!.id),
                  ),
                ],
              ],
            ),
            body: isLoading
                ? const Center(child: CircularProgressIndicator())
                : employee == null
                    ? const Center(child: Text('Employee not found'))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profile Card
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 40,
                                      child: Text(
                                        employee.name[0].toUpperCase(),
                                        style: const TextStyle(fontSize: 32),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      employee.name,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      employee.position,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Contact Information
                            const Text(
                              'Contact Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoCard(
                                Icons.email, 'Email', employee.email),
                            _buildInfoCard(
                                Icons.phone, 'Phone', employee.phone),

                            const SizedBox(height: 24),

                            // Work Information
                            const Text(
                              'Work Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoCard(Icons.business, 'Department',
                                employee.department),
                            _buildInfoCard(
                                Icons.work, 'Position', employee.position),
                            _buildInfoCard(
                              Icons.calendar_today,
                              'Join Date',
                              dateFormat.format(employee.joinDate),
                            ),
                            _buildInfoCard(
                              Icons.timeline,
                              'Years of Service',
                              '${_calculateYearsOfService(employee)} years',
                            ),
                            _buildInfoCard(
                              Icons.attach_money,
                              'Salary',
                              currencyFormat.format(employee.salary),
                            ),
                          ],
                        ),
                      ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(label, style: const TextStyle(fontSize: 12)),
        subtitle: Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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
              employeeDetailBloc.add(EmployeeDetailDeleteTriggered(id));
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
    employeeDetailBloc.close();
    super.dispose();
  }
}
