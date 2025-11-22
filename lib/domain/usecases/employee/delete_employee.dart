import '../../repositories/employee_repository.dart';

class DeleteEmployee {
  final EmployeeRepository repository;

  DeleteEmployee(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteEmployee(id);
  }
}

