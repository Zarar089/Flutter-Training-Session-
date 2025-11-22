import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../presentation/bloc/employee/employee_bloc.dart';
import '../presentation/bloc/employee/employee_event.dart';
import '../presentation/bloc/employee/employee_state.dart';
import '../domain/entities/employee.dart';

class EmployeeAddScreen extends StatefulWidget {
  final Employee? employee;

  const EmployeeAddScreen({Key? key, this.employee}) : super(key: key);

  @override
  State<EmployeeAddScreen> createState() => _EmployeeAddScreenState();
}

class _EmployeeAddScreenState extends State<EmployeeAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _positionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _salaryController = TextEditingController();

  String _selectedDepartment = 'Engineering';
  DateTime _joinDate = DateTime.now();
  bool _isDraftSaved = false;

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
    } else {
      _loadDraftIfExists();
    }
  }

  Future<void> _loadDraftIfExists() async {
    final prefs = await SharedPreferences.getInstance();
    final draftName = prefs.getString('draft_employee_name');

    if (draftName != null) {
      _nameController.text = draftName;
      _emailController.text = prefs.getString('draft_employee_email') ?? '';
      _positionController.text = prefs.getString('draft_employee_position') ?? '';
      _phoneController.text = prefs.getString('draft_employee_phone') ?? '';
      _salaryController.text = prefs.getString('draft_employee_salary') ?? '';
      _selectedDepartment = prefs.getString('draft_employee_department') ?? 'Engineering';
      setState(() => _isDraftSaved = true);
    }
  }

  Future<void> _saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('draft_employee_name', _nameController.text);
    await prefs.setString('draft_employee_email', _emailController.text);
    await prefs.setString('draft_employee_position', _positionController.text);
    await prefs.setString('draft_employee_phone', _phoneController.text);
    await prefs.setString('draft_employee_salary', _salaryController.text);
    await prefs.setString('draft_employee_department', _selectedDepartment);

    setState(() => _isDraftSaved = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Draft saved')),
    );
  }

  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('draft_employee_name');
    await prefs.remove('draft_employee_email');
    await prefs.remove('draft_employee_position');
    await prefs.remove('draft_employee_phone');
    await prefs.remove('draft_employee_salary');
    await prefs.remove('draft_employee_department');
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

    final employee = Employee(
      id: widget.employee?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      email: _emailController.text,
      position: _positionController.text,
      department: _selectedDepartment,
      joinDate: _joinDate,
      phone: _phoneController.text,
      salary: double.parse(_salaryController.text),
    );

    if (widget.employee == null) {
      context.read<EmployeeBloc>().add(AddEmployee(employee));
      _clearDraft();
    } else {
      context.read<EmployeeBloc>().add(UpdateEmployee(employee));
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
    return BlocListener<EmployeeBloc, EmployeeState>(
      listener: (context, state) {
        if (state is EmployeeOperationSuccess) {
          if (context.mounted) {
            Navigator.pop(context, true);
          }
        } else if (state is EmployeeError) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.employee == null ? 'Add Employee' : 'Edit Employee'),
          actions: [
            if (widget.employee == null)
              IconButton(
                icon: Icon(_isDraftSaved ? Icons.save : Icons.save_outlined),
                onPressed: _saveDraft,
                tooltip: 'Save Draft',
              ),
          ],
        ),
        body: BlocBuilder<EmployeeBloc, EmployeeState>(
          builder: (context, state) {
            final isLoading = state is EmployeeOperationLoading;

            return isLoading
                ? const Center(child: CircularProgressIndicator())
                : Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (_isDraftSaved && widget.employee == null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue.shade700),
                                const SizedBox(width: 8),
                                const Expanded(child: Text('Draft loaded')),
                                TextButton(
                                  onPressed: () async {
                                    await _clearDraft();
                                    setState(() {
                                      _nameController.clear();
                                      _emailController.clear();
                                      _positionController.clear();
                                      _phoneController.clear();
                                      _salaryController.clear();
                                      _isDraftSaved = false;
                                    });
                                  },
                                  child: const Text('Clear'),
                                ),
                              ],
                            ),
                          ),

                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
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
                          onChanged: (value) {
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
                          onTap: _selectDate,
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
                          onPressed: _saveEmployee,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                          child: Text(
                            widget.employee == null ? 'Add Employee' : 'Update Employee',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  );
          },
        ),
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
