import '../../entities/employee.dart';
import '../../repositories/employee_repository.dart';

class AddEmployeeUseCase {
  final EmployeeRepository repository;

  AddEmployeeUseCase(this.repository);

  Future<void> call(Employee employee) async {
    return await repository.addEmployee(employee);
  }
}

