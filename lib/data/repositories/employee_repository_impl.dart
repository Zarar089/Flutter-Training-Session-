import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/employee_entity.dart';
import '../../domain/repositories/employee_repository.dart';
import '../datasources/local/realm_datasource.dart';
import '../datasources/local/shared_pref_datasource.dart';
import '../datasources/remote/firebase_datasource.dart';
import '../datasources/local/realm_schemas/employee_realm.dart';
import '../models/employee_model.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final FirebaseDataSource firebaseDataSource;
  final RealmDataSource<EmployeeRealm> realmDataSource;
  final SharedPrefDataSource sharedPrefDataSource;

  EmployeeRepositoryImpl({
    required this.firebaseDataSource,
    required this.realmDataSource,
    required this.sharedPrefDataSource,
  });

  @override
  Future<Either<Failure, List<EmployeeEntity>>> getEmployees() async {
    try {
      // Try to fetch from Firebase
      final firebaseData = await firebaseDataSource.getAll();
      
      final employees = firebaseData.entries.map((entry) {
        final data = Map<String, dynamic>.from(entry.value as Map);
        data['id'] = entry.key;
        return EmployeeModel.fromJson(data);
      }).toList();

      // Cache to Realm
      realmDataSource.deleteAll();
      final realmEmployees = employees.map((emp) => EmployeeRealm(
        emp.id,
        emp.name,
        emp.email,
        emp.position,
        emp.department,
        emp.joinDate,
        emp.phone,
        emp.salary,
      )).toList();
      realmDataSource.insertAll(realmEmployees);

      // Update last sync time
      await sharedPrefDataSource.setString(
        'last_sync_employees',
        DateTime.now().toIso8601String(),
      );

      return Right(employees);
    } on ServerException catch (e) {
      // Fallback to Realm cache
      try {
        final realmEmployees = realmDataSource.getAll();
        final employees = realmEmployees.map((emp) => EmployeeEntity(
          id: emp.id,
          name: emp.name,
          email: emp.email,
          position: emp.position,
          department: emp.department,
          joinDate: emp.joinDate,
          phone: emp.phone,
          salary: emp.salary,
        )).toList();
        return Right(employees);
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, EmployeeEntity>> getEmployeeById(String id) async {
    try {
      final firebaseData = await firebaseDataSource.getById(id);
      if (firebaseData != null) {
        firebaseData['id'] = id;
        return Right(EmployeeModel.fromJson(firebaseData));
      }
      return Left(ServerFailure('Employee not found'));
    } on ServerException catch (e) {
      // Fallback to Realm
      try {
        final realmEmployee = realmDataSource.findById(id);
        if (realmEmployee != null) {
          return Right(EmployeeEntity(
            id: realmEmployee.id,
            name: realmEmployee.name,
            email: realmEmployee.email,
            position: realmEmployee.position,
            department: realmEmployee.department,
            joinDate: realmEmployee.joinDate,
            phone: realmEmployee.phone,
            salary: realmEmployee.salary,
          ));
        }
        return Left(CacheFailure('Employee not found in cache'));
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }

  @override
  Future<Either<Failure, void>> addEmployee(EmployeeEntity employee) async {
    try {
      final employeeModel = EmployeeModel.fromEntity(employee);
      await firebaseDataSource.insert(employee.id, employeeModel.toJson());

      // Cache to Realm
      realmDataSource.insert(EmployeeRealm(
        employee.id,
        employee.name,
        employee.email,
        employee.position,
        employee.department,
        employee.joinDate,
        employee.phone,
        employee.salary,
      ));

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateEmployee(EmployeeEntity employee) async {
    try {
      final employeeModel = EmployeeModel.fromEntity(employee);
      await firebaseDataSource.update(employee.id, employeeModel.toJson());

      // Update in Realm
      realmDataSource.insert(EmployeeRealm(
        employee.id,
        employee.name,
        employee.email,
        employee.position,
        employee.department,
        employee.joinDate,
        employee.phone,
        employee.salary,
      ));

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEmployee(String id) async {
    try {
      await firebaseDataSource.delete(id);

      // Delete from Realm
      final realmEmployee = realmDataSource.findById(id);
      if (realmEmployee != null) {
        realmDataSource.delete(realmEmployee);
      }

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<EmployeeEntity>>> searchEmployees(String query) async {
    try {
      final result = await getEmployees();
      return result.fold(
        (failure) => Left(failure),
        (employees) {
          final filtered = employees.where((emp) {
            final lowerQuery = query.toLowerCase();
            return emp.name.toLowerCase().contains(lowerQuery) ||
                emp.position.toLowerCase().contains(lowerQuery) ||
                emp.department.toLowerCase().contains(lowerQuery);
          }).toList();
          return Right(filtered);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to search employees: $e'));
    }
  }
}