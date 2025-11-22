import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/employee_entity.dart';
import '../bloc/employee_form/employee_form_bloc.dart';
import '../bloc/employee_form/employee_form_event.dart';
import '../bloc/employee_form/employee_form_state.dart';

class EmployeeFormScreen extends StatefulWidget {
  final EmployeeEntity? employee;

  const EmployeeFormScreen({Key? key, this.employee}) : super(key: key);

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _positionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _salaryController = TextEditingController();

  String _selectedDepartment = 'Engineering';
  DateTime _joinDate = DateTime.now();

  final List<String> departments = [
    'Engineering',
    'Marketing',
    'Sales',
    'HR',
    'Finance',
    'Operations',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      _loadEmployeeData();
    }
  }

  void _loadEmployeeData() {
    final emp = widget.employee!;
    _nameController.text = emp.name;
    _emailController.text = emp.email;
    _positionController.text = emp.position;
    _phoneController.text = emp.phone;
    _salaryController.text = emp.salary.toString();
    _selectedDepartment = emp.department;
    _joinDate = emp.joinDate;
  }

  void _saveEmployee() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final employeeId = widget.employee?.id ?? 
        DateTime.now().millisecondsSinceEpoch.toString();

    final employee = EmployeeEntity(
      id: employeeId,
      name: _nameController.text,
      email: _emailController.text,
      position: _positionController.text,
      department: _selectedDepartment,
      joinDate: _joinDate,
      phone: _phoneController.text,
      salary: double.parse(_salaryController.text),
    );

    if (widget.employee == null) {
      context.read<EmployeeFormBloc>().add(AddEmployeeEvent(employee));
    } else {
      context.read<EmployeeFormBloc>().add(UpdateEmployeeEvent(employee));
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _joinDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _joinDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.employee == null ? 'Add Employee' : 'Edit Employee'),
      ),
      body: BlocConsumer<EmployeeFormBloc, EmployeeFormState>(
        listener: (context, state) {
          if (state is EmployeeFormSuccess) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(widget.employee == null
                    ? 'Employee added successfully'
                    : 'Employee updated successfully'),
              ),
            );
          } else if (state is EmployeeFormError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is EmployeeFormLoading;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  enabled: !isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  enabled: !isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _positionController,
                  decoration: const InputDecoration(
                    labelText: 'Position',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.work),
                  ),
                  enabled: !isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter position';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedDepartment,
                  decoration: const InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                  items: departments.map((dept) {
                    return DropdownMenuItem(value: dept, child: Text(dept));
                  }).toList(),
                  onChanged: isLoading
                      ? null
                      : (value) {
                          setState(() => _selectedDepartment = value!);
                        },
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Join Date'),
                  subtitle: Text(DateFormat('MMM dd, yyyy').format(_joinDate)),
                  trailing: const Icon(Icons.edit),
                  onTap: isLoading ? null : _selectDate,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  enabled: !isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _salaryController,
                  decoration: const InputDecoration(
                    labelText: 'Salary',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  enabled: !isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter salary';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading ? null : _saveEmployee,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          widget.employee == null
                              ? 'Add Employee'
                              : 'Update Employee',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _positionController.dispose();
    _phoneController.dispose();
    _salaryController.dispose();
    super.dispose();
  }
}