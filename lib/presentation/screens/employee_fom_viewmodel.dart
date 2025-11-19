// lib/presentation/screens/employee_form_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/employee.dart';
import '../../domain/usecases/add_employee.dart';
import '../../domain/usecases/update_employee.dart';
import '../../../core/di/service_locator.dart' as di;

class EmployeeFormViewModel extends ChangeNotifier {
  final AddEmployee addEmployee = di.sl<AddEmployee>();
  final UpdateEmployee updateEmployee = di.sl<UpdateEmployee>();

  // Form controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final positionController = TextEditingController();
  final phoneController = TextEditingController();
  final salaryController = TextEditingController();

  String selectedDepartment = 'Engineering';
  DateTime joinDate = DateTime.now();
  bool isLoading = false;
  String? error;

  final List<String> departments = [
    'Engineering', 'Marketing', 'Sales', 'HR', 'Finance', 'Operations'
  ];

  // For edit mode
  void loadEmployee(Employee? employee) {
    if (employee == null) return;

    nameController.text = employee.name;
    emailController.text = employee.email;
    positionController.text = employee.position;
    phoneController.text = employee.phone;
    salaryController.text = employee.salary.toString();
    selectedDepartment = employee.department;
    joinDate = DateTime.parse(employee.joinDate);
    notifyListeners();
  }

  bool validate() {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        !emailController.text.contains('@') ||
        positionController.text.isEmpty ||
        phoneController.text.isEmpty ||
        salaryController.text.isEmpty ||
        double.tryParse(salaryController.text) == null) {
      return false;
    }
    return true;
  }

  Future<bool> save(Employee? existingEmployee) async {
    if (!validate()) return false;

    isLoading = true;
    notifyListeners();

    try {
      final employee = Employee(
        id: existingEmployee?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameController.text,
        email: emailController.text,
        position: positionController.text,
        department: selectedDepartment,
        joinDate: joinDate.toIso8601String(),
        phone: phoneController.text,
        salary: double.parse(salaryController.text).toInt(),
      );

      if (existingEmployee == null) {
        await addEmployee(employee);
      } else {
        await updateEmployee(employee);
      }

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    positionController.dispose();
    phoneController.dispose();
    salaryController.dispose();
    super.dispose();
  }
}