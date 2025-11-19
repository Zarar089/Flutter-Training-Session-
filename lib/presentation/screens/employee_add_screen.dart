// lib/presentation/screens/employee_add_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/employee.dart';
import 'employee_fom_viewmodel.dart';

class EmployeeAddScreen extends StatefulWidget {
  final Employee? employee;

  const EmployeeAddScreen({Key? key, this.employee}) : super(key: key);

  @override
  State<EmployeeAddScreen> createState() => _EmployeeAddScreenState();
}

class _EmployeeAddScreenState extends State<EmployeeAddScreen> {
  late final viewModel = EmployeeFormViewModel()..loadEmployee(widget.employee);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.employee == null ? 'Add Employee' : 'Edit Employee'),
      ),
      body: AnimatedBuilder(
        animation: viewModel,
        builder: (context, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Form(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(controller: viewModel.nameController, decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person)), validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 16),
                TextFormField(controller: viewModel.emailController, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)), keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                TextFormField(controller: viewModel.positionController, decoration: const InputDecoration(labelText: 'Position', prefixIcon: Icon(Icons.work))),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: viewModel.selectedDepartment,
                  items: viewModel.departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (v) => setState(() => viewModel.selectedDepartment = v!),
                  decoration: const InputDecoration(labelText: 'Department', prefixIcon: Icon(Icons.business)),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Join Date'),
                  subtitle: Text(DateFormat('MMM dd, yyyy').format(viewModel.joinDate)),
                  trailing: const Icon(Icons.edit),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: viewModel.joinDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      viewModel.joinDate = picked;
                      viewModel.notifyListeners();
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(controller: viewModel.phoneController, decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone)), keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                TextFormField(controller: viewModel.salaryController, decoration: const InputDecoration(labelText: 'Salary', prefixIcon: Icon(Icons.attach_money)), keyboardType: TextInputType.number),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    final success = await viewModel.save(widget.employee);
                    if (success && mounted) Navigator.pop(context, true);
                  },
                  child: Text(widget.employee == null ? 'Add Employee' : 'Update Employee'),
                ),
                if (viewModel.error != null)
                  Padding(padding: const EdgeInsets.all(8), child: Text(viewModel.error!, style: const TextStyle(color: Colors.red))),
              ],
            ),
          );
        },
      ),
    );
  }
}