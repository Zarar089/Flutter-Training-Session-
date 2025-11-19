import '../entities/employee.dart';

abstract class EmployeeRepository {
  Future<List<Employee>> getEmployees();
  Future<void> deleteEmployee(String id);
  Future<void> addEmployee(Employee employee);
  Future<void> updateEmployee(Employee employee); // ← Add this
}