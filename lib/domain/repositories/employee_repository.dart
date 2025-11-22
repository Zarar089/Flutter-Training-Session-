import '../entities/employee.dart';

abstract class EmployeeRepository {
  Future<List<Employee>> getEmployees();
  Future<Employee> getEmployeeById(String id);
  Future<void> addEmployee(Employee employee);
  Future<void> updateEmployee(Employee employee);
  Future<void> deleteEmployee(String id);
  Future<List<Employee>> searchEmployees(String query);
}

