import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/employee_entity.dart';
import '../../repositories/employee_repository.dart';

class UpdateEmployee {
  final EmployeeRepository repository;

  UpdateEmployee(this.repository);

  Future<Either<Failure, void>> call(EmployeeEntity employee) async {
    return await repository.updateEmployee(employee);
  }
}