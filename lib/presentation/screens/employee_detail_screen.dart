// lib/presentation/screens/employee_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/employee.dart';
import 'employee_add_screen.dart';
import '../../../core/di/service_locator.dart' as di;
import 'employee_list_viewmodel.dart';

class EmployeeDetailScreen extends StatelessWidget {
  final Employee employee;

  const EmployeeDetailScreen({Key? key, required this.employee}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = di.sl<EmployeeListViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Details'),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EmployeeAddScreen(employee: employee)),
            ).then((_) => viewModel.loadEmployees());
          }),
          IconButton(icon: const Icon(Icons.delete), onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Delete?'),
                content: Text('Delete ${employee.name}?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      viewModel.delete(employee.id);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(radius: 50, child: Text(employee.name[0].toUpperCase(), style: const TextStyle(fontSize: 40))),
            const SizedBox(height: 16),
            Text(employee.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Text(employee.position, style: TextStyle(fontSize: 18, color: Colors.grey[600])),
            const SizedBox(height: 30),
            _infoTile(Icons.email, 'Email', employee.email),
            _infoTile(Icons.phone, 'Phone', employee.phone),
            _infoTile(Icons.business, 'Department', employee.department),
            _infoTile(Icons.calendar_today, 'Join Date', DateFormat('MMM dd, yyyy').format(DateTime.parse(employee.joinDate))),
            _infoTile(Icons.attach_money, 'Salary', '\$${employee.salary}'),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(leading: Icon(icon, color: Colors.blue), title: Text(label), subtitle: Text(value, style: const TextStyle(fontSize: 16))),
    );
  }
}