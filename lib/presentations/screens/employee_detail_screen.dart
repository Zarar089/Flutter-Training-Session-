import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/employee.dart';
import 'employee_add_screen.dart';

// ⚠️ SPAGHETTI CODE - ALL LOGIC IN ONE FILE
class EmployeeDetailScreen extends StatefulWidget {
  final Employee employee;

  const EmployeeDetailScreen({super.key, required this.employee});

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  bool isLoading = false;

  // Navigate to edit screen
  void _navigateToEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeAddScreen(employee: {
          'id': widget.employee.id,
          'name': widget.employee.name,
          'email': widget.employee.email,
          'phone': widget.employee.phone,
          'department': widget.employee.department,
          'position': widget.employee.position,
          'joinDate': widget.employee.joinDate,
          'salary': widget.employee.salary,
        }),
      ),
    ).then((updated) {
      if (!mounted) return;
      if (updated == true) {
        Navigator.pop(context, true);
      }
    });
  }

  int _calculateYearsOfService() {
    final joinDate = widget.employee.joinDate;
    final now = DateTime.now();
    return now.year - joinDate.year;
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
            onPressed: _navigateToEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _showDeleteDialog,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
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
                              widget.employee.name.toString()[0].toUpperCase(),
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.employee.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.employee.position,
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
                  _buildInfoCard(Icons.email, 'Email', widget.employee.email),
                  _buildInfoCard(Icons.phone, 'Phone', widget.employee.phone),

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
                  _buildInfoCard(
                      Icons.business, 'Department', widget.employee.department),
                  _buildInfoCard(
                      Icons.work, 'Position', widget.employee.position),
                  _buildInfoCard(
                    Icons.calendar_today,
                    'Join Date',
                    dateFormat.format(widget.employee.joinDate),
                  ),
                  _buildInfoCard(
                    Icons.timeline,
                    'Years of Service',
                    '${_calculateYearsOfService()} years',
                  ),
                  _buildInfoCard(
                    Icons.attach_money,
                    'Salary',
                    currencyFormat.format(widget.employee.salary),
                  ),
                ],
              ),
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

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content:
            Text('Are you sure you want to delete ${widget.employee.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Return a simple result to the caller; actual deletion should be handled by the list/bloc/usecase layer.
              Navigator.pop(context, true);
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
