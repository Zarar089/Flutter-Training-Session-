import '../../entities/employee.dart';
import '../../repositories/employee_repository.dart';

class GetEmployeesUseCase {
  final EmployeeRepository repository;

  GetEmployeesUseCase(this.repository);

  Future<List<Employee>> call() async {
    return await repository.getEmployees();
  }
}

