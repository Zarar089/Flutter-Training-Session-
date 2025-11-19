// lib/domain/usecases/update_employee.dart
import '../entities/employee.dart';
import '../repositories/employee_repository.dart';

class UpdateEmployee {
  final EmployeeRepository repository;

  UpdateEmployee(this.repository);

  Future<void> call(Employee employee) {
    return repository.addEmployee(employee); // Firebase uses .set() → works for update too
  }
}