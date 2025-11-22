import '../../entities/employee.dart';
import '../../repositories/employee_repository.dart';

class UpdateEmployeeUseCase {
  final EmployeeRepository repository;

  UpdateEmployeeUseCase(this.repository);

  Future<void> call(Employee employee) async {
    return await repository.updateEmployee(employee);
  }
}

