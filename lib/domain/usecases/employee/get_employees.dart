import '../../entities/employee.dart';
import '../../repositories/employee_repository.dart';

class GetEmployees {
  final EmployeeRepository repository;

  GetEmployees(this.repository);

  Future<List<Employee>> call() async {
    return await repository.getEmployees();
  }
}

