import 'package:flutter/material.dart';
import '../../domain/entities/employee.dart';
import '../../domain/repositories/employee_repository.dart';
import '../../../core/di/service_locator.dart' as di;

class EmployeeListViewModel extends ChangeNotifier {
  final EmployeeRepository repo = di.sl<EmployeeRepository>();

  List<Employee> employees = [];
  List<Employee> filtered = [];
  bool isLoading = false;
  String? error;

  Future<void> loadEmployees() async {
    isLoading = true;
    notifyListeners();

    try {
      employees = await repo.getEmployees();
      filtered = employees;
      error = null;
    } catch (e) {
      error = "Offline mode";
    }

    isLoading = false;
    notifyListeners();
  }

  void search(String query) {
    if (query.isEmpty) {
      filtered = employees;
    } else {
      filtered = employees
          .where((e) => e.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await repo.deleteEmployee(id);
    await loadEmployees();
  }
}