import '../../entities/employee.dart';
import '../../repositories/employee_repository.dart';

class GetEmployeeByIdUseCase {
  final EmployeeRepository repository;

  GetEmployeeByIdUseCase(this.repository);

  Future<Employee> call(String id) async {
    return await repository.getEmployeeById(id);
  }
}

