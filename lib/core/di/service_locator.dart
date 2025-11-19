import 'package:get_it/get_it.dart';
import '../../data/repositories/employee_repository_impl.dart';
import '../../data/data_source/remote/firebase_employee_datasource.dart';
import '../../data/data_source/local/realm_employee_datasource.dart';
import '../../domain/repositories/employee_repository.dart';
import '../../domain/usecases/add_employee.dart';
import '../../domain/usecases/update_employee.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Data sources
  sl.registerLazySingleton<FirebaseEmployeeDataSource>(() => FirebaseEmployeeDataSource());
  sl.registerLazySingleton<RealmEmployeeDataSource>(() => RealmEmployeeDataSource());
  sl.registerLazySingleton(() => AddEmployee(sl()));
  sl.registerLazySingleton(() => UpdateEmployee(sl()));

  // Repository
  sl.registerLazySingleton<EmployeeRepository>(
        () => EmployeeRepositoryImpl(sl(), sl()),
  );
}