import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/employee_repository.dart';

class DeleteEmployee {
  final EmployeeRepository repository;

  DeleteEmployee(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteEmployee(id);
  }
}