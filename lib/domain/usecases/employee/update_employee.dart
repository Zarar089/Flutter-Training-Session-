import '../../entities/employee.dart';
import '../../repositories/employee_repository.dart';

class UpdateEmployee {
  final EmployeeRepository repository;

  UpdateEmployee(this.repository);

  Future<void> call(Employee employee) async {
    return await repository.updateEmployee(employee);
  }
}

