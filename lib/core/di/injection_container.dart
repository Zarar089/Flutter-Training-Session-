import 'package:get_it/get_it.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:realm/realm.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Data Sources
import '../../data/datasources/local/realm_datasource.dart';
import '../../data/datasources/local/shared_pref_datasource.dart';
import '../../data/datasources/remote/firebase_datasource.dart';
import '../../data/datasources/local/realm_schemas/employee_realm.dart';
import '../../data/datasources/local/realm_schemas/attendance_realm.dart';

// Repositories
import '../../data/repositories/employee_repository_impl.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../domain/repositories/employee_repository.dart';
import '../../domain/repositories/attendance_repository.dart';

// Use Cases - Employee
import '../../domain/usecases/employee/get_employees.dart';
import '../../domain/usecases/employee/add_employee.dart';
import '../../domain/usecases/employee/update_employee.dart';
import '../../domain/usecases/employee/delete_employee.dart';
import '../../domain/usecases/employee/search_employees.dart';

// Use Cases - Attendance
import '../../domain/usecases/attendance/get_attendance.dart';
import '../../domain/usecases/attendance/check_in.dart';
import '../../domain/usecases/attendance/check_out.dart';
import '../../domain/usecases/attendance/get_monthly_stats.dart';

// BLoC - FIXED: Keep 'presentations' with 's' to match actual folder structure
import '../../presentations/bloc/employee_list/employee_list_bloc.dart';
import '../../presentations/bloc/employee_form/employee_form_bloc.dart';
import '../../presentations/bloc/employee_detail/employee_detail_bloc.dart';
import '../../presentations/bloc/attendance/attendance_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Employee
  // Bloc
  sl.registerFactory(
    () => EmployeeListBloc(
      getEmployees: sl(),
      searchEmployees: sl(),
      deleteEmployee: sl(),
    ),
  );

  sl.registerFactory(
    () => EmployeeFormBloc(
      addEmployee: sl(),
      updateEmployee: sl(),
    ),
  );

  sl.registerFactory(
    () => EmployeeDetailBloc(
      deleteEmployee: sl(),
    ),
  );

  // Use cases - Employee
  sl.registerLazySingleton(() => GetEmployees(sl()));
  sl.registerLazySingleton(() => AddEmployee(sl()));
  sl.registerLazySingleton(() => UpdateEmployee(sl()));
  sl.registerLazySingleton(() => DeleteEmployee(sl()));
  sl.registerLazySingleton(() => SearchEmployees(sl()));

  // Repository - Employee
  sl.registerLazySingleton<EmployeeRepository>(
    () => EmployeeRepositoryImpl(
      firebaseDataSource: sl(),
      realmDataSource: sl(),
      sharedPrefDataSource: sl(),
    ),
  );

  //! Features - Attendance
  // Bloc
  sl.registerFactory(
    () => AttendanceBloc(
      getAttendance: sl(),
      checkIn: sl(),
      checkOut: sl(),
      getMonthlyStats: sl(),
    ),
  );

  // Use cases - Attendance
  sl.registerLazySingleton(() => GetAttendance(sl()));
  sl.registerLazySingleton(() => CheckIn(sl()));
  sl.registerLazySingleton(() => CheckOut(sl()));
  sl.registerLazySingleton(() => GetMonthlyStats(sl()));

  // Repository - Attendance
  sl.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(
      firebaseDataSource: sl<FirebaseDataSource>(instanceName: 'attendance'),
      realmDataSource: sl<RealmDataSource<AttendanceRealm>>(instanceName: 'attendance'),
    ),
  );

  //! Core

  //! External
  // Firebase - Employee
  final firebaseEmployeeRef = FirebaseDatabase.instance.ref('employees');
  sl.registerLazySingleton(() => FirebaseDataSource(firebaseEmployeeRef));

  // Firebase - Attendance
  final firebaseAttendanceRef = FirebaseDatabase.instance.ref('attendance');
  sl.registerLazySingleton(
    () => FirebaseDataSource(firebaseAttendanceRef),
    instanceName: 'attendance',
  );

  // Realm
  final realmConfig = Configuration.local([
    EmployeeRealm.schema,
    AttendanceRealm.schema,
  ]);
  final realm = Realm(realmConfig);
  
  sl.registerLazySingleton(() => RealmDataSource<EmployeeRealm>(realm));
  sl.registerLazySingleton(
    () => RealmDataSource<AttendanceRealm>(realm),
    instanceName: 'attendance',
  );

  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => SharedPrefDataSource(sharedPreferences));
}