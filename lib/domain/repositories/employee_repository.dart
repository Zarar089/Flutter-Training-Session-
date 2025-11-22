import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/employee_entity.dart';

abstract class EmployeeRepository {
  Future<Either<Failure, List<EmployeeEntity>>> getEmployees();
  Future<Either<Failure, EmployeeEntity>> getEmployeeById(String id);
  Future<Either<Failure, void>> addEmployee(EmployeeEntity employee);
  Future<Either<Failure, void>> updateEmployee(EmployeeEntity employee);
  Future<Either<Failure, void>> deleteEmployee(String id);
  Future<Either<Failure, List<EmployeeEntity>>> searchEmployees(String query);
}