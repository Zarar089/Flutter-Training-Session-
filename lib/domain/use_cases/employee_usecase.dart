import 'package:employee_app_v1_spaghetti/domain/entities/employee.dart';
import 'package:employee_app_v1_spaghetti/domain/repositories/i_employee_repository.dart';

class EmployeeUseCase {
  final IEmployeeRepository _repository;

  EmployeeUseCase(this._repository);

  Future<List<Employee>> fetchEmployeeData() async {
    return await _repository.getEmployees();
  }

  Future<void> addEmployee(Employee employee) async {
    await _repository.addEmployee(employee);
  }

  Future<void> updateEmployee(Employee employee) async {
    await _repository.updateEmployee(employee);
  }

  Future<void> deleteEmployee(String id) async {
    await _repository.deleteEmployee(id);
  }

  Future<Employee?> getEmployeeById(String id) async {
    return await _repository.getEmployeeById(id);
  }
}
