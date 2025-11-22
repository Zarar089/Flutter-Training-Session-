import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/employee_entity.dart';
import '../../repositories/employee_repository.dart';

class SearchEmployees {
  final EmployeeRepository repository;

  SearchEmployees(this.repository);

  Future<Either<Failure, List<EmployeeEntity>>> call(String query) async {
    return await repository.searchEmployees(query);
  }
}