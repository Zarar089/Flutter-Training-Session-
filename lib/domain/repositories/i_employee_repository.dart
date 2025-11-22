import '../entities/employee.dart';

abstract class IEmployeeRepository {
  Future<List<Employee>> getEmployees();
  Future<void> addEmployee(Employee employee);
  Future<void> updateEmployee(Employee employee);
  Future<void> deleteEmployee(String id);
  Future<Employee?> getEmployeeById(String id);
}
