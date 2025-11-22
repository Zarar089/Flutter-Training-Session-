import '../../entities/employee.dart';
import '../../repositories/employee_repository.dart';

class GetEmployeeById {
  final EmployeeRepository repository;

  GetEmployeeById(this.repository);

  Future<Employee> call(String id) async {
    return await repository.getEmployeeById(id);
  }
}

