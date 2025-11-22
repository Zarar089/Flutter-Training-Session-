import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/employee_entity.dart';
import '../bloc/employee_detail/employee_detail_bloc.dart';
import '../bloc/employee_detail/employee_detail_event.dart';
import '../bloc/employee_detail/employee_detail_state.dart';
import 'employee_form_screen.dart';

class EmployeeDetailScreen extends StatelessWidget {
  final EmployeeEntity employee;

  const EmployeeDetailScreen({Key? key, required this.employee}) : super(key: key);

  int _calculateYearsOfService() {
    final now = DateTime.now();
    return now.year - employee.joinDate.year;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EmployeeFormScreen(employee: employee),
                ),
              ).then((updated) {
                if (updated == true) {
                  Navigator.pop(context, true);
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: BlocConsumer<EmployeeDetailBloc, EmployeeDetailState>(
        listener: (context, state) {
          if (state is EmployeeDetailDeleted) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Employee deleted successfully')),
            );
          } else if (state is EmployeeDetailError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is EmployeeDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                const Text(
                  'Contact Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoCard(Icons.email, 'Email', employee.email),
                _buildInfoCard(Icons.phone, 'Phone', employee.phone),
                const SizedBox(height: 24),
                const Text(
                  'Work Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoCard(Icons.business, 'Department', employee.department),
                _buildInfoCard(Icons.work, 'Position', employee.position),
                _buildInfoCard(
                  Icons.calendar_today,
                  'Join Date',
                  dateFormat.format(employee.joinDate),
                ),
                _buildInfoCard(
                  Icons.timeline,
                  'Years of Service',
                  '${_calculateYearsOfService()} years',
                ),
                _buildInfoCard(
                  Icons.attach_money,
                  'Salary',
                  currencyFormat.format(employee.salary),
                ),
              ],
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
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to delete ${employee.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context
                  .read<EmployeeDetailBloc>()
                  .add(DeleteEmployeeDetailEvent(employee.id));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}