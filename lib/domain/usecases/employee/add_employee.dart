import '../../entities/employee.dart';
import '../../repositories/employee_repository.dart';

class AddEmployee {
  final EmployeeRepository repository;

  AddEmployee(this.repository);

  Future<void> call(Employee employee) async {
    return await repository.addEmployee(employee);
  }
}

