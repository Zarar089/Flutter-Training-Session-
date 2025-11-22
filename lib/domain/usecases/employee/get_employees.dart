import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/employee_entity.dart';
import '../../repositories/employee_repository.dart';

class GetEmployees {
  final EmployeeRepository repository;

  GetEmployees(this.repository);

  Future<Either<Failure, List<EmployeeEntity>>> call() async {
    return await repository.getEmployees();
  }
}