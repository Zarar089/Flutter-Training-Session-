import '../../entities/employee.dart';
import '../../repositories/employee_repository.dart';

class SearchEmployeesUseCase {
  final EmployeeRepository repository;

  SearchEmployeesUseCase(this.repository);

  Future<List<Employee>> call(String query) async {
    return await repository.searchEmployees(query);
  }
}

