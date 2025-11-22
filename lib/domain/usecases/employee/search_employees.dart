import '../../entities/employee.dart';
import '../../repositories/employee_repository.dart';

class SearchEmployees {
  final EmployeeRepository repository;

  SearchEmployees(this.repository);

  Future<List<Employee>> call(String query) async {
    return await repository.searchEmployees(query);
  }
}

