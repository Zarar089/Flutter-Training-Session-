import 'package:firebase_database/firebase_database.dart';
import 'package:get_it/get_it.dart';
import 'package:realm/realm.dart';
import '../bloc/attendance/attendance_bloc.dart';
import '../bloc/employee/employee_bloc.dart';
import '../data/models/reals_models/attendence/attendance_model.dart';
import '../data/models/reals_models/employee/employee_model.dart';
import '../data/repositories/attendance_repository_impl.dart';
import '../data/repositories/employee_repository_impl.dart';
import '../domain/repositories/attendance_repository.dart';
import '../domain/repositories/employee_repository.dart';
import '../domain/usecases/attendance/get_attendance_by_employee_id.dart';
import '../domain/usecases/attendance/get_attendance_records.dart';
import '../domain/usecases/attendance/get_monthly_hours.dart';
import '../domain/usecases/attendance/mark_check_in.dart';
import '../domain/usecases/attendance/mark_check_out.dart';
import '../domain/usecases/employee/add_employee.dart';
import '../domain/usecases/employee/delete_employee.dart';
import '../domain/usecases/employee/get_employees.dart';
import '../domain/usecases/employee/search_employees.dart';
import '../domain/usecases/employee/update_employee.dart';

/// GetIt instance - This is our Dependency Injection container
/// GetIt is a simple Service Locator for Dart and Flutter
final getIt = GetIt.instance;

/// Initialize all dependencies
/// This function registers all our dependencies with GetIt
/// 
/// How GetIt works:
/// 1. We register dependencies using getIt.registerLazySingleton() or getIt.registerFactory()
/// 2. Later, we can retrieve them using getIt<T>() or getIt.get<T>()
/// 3. GetIt manages the lifecycle of these dependencies
Future<void> init() async {
  // ============================================
  // STEP 1: Register Core Dependencies (Realm, Firebase)
  // ============================================
  
  // Initialize Realm
  final realmConfig = Configuration.local([
    EmployeeRealm.schema,
    Attendance.schema,
  ]);
  final realm = Realm(realmConfig);
  
  // Register Realm as a singleton (one instance for the entire app)
  getIt.registerLazySingleton<Realm>(() => realm);
  
  // Register Firebase Database References
  getIt.registerLazySingleton<DatabaseReference>(
    () => FirebaseDatabase.instance.ref('employees'),
    instanceName: 'employeesRef',
  );
  
  getIt.registerLazySingleton<DatabaseReference>(
    () => FirebaseDatabase.instance.ref('attendance'),
    instanceName: 'attendanceRef',
  );

  // ============================================
  // STEP 2: Register Repositories
  // ============================================
  
  // Register EmployeeRepository
  // registerLazySingleton: Creates instance only when first accessed, then reuses it
  getIt.registerLazySingleton<EmployeeRepository>(
    () => EmployeeRepositoryImpl(
      getIt<DatabaseReference>(instanceName: 'employeesRef'),
      getIt<Realm>(),
    ),
  );
  
  // Register AttendanceRepository
  getIt.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(
      getIt<DatabaseReference>(instanceName: 'attendanceRef'),
      getIt<DatabaseReference>(instanceName: 'employeesRef'),
      getIt<Realm>(),
    ),
  );

  // ============================================
  // STEP 3: Register Use Cases
  // ============================================
  
  // Employee Use Cases
  getIt.registerLazySingleton<GetEmployees>(
    () => GetEmployees(getIt<EmployeeRepository>()),
  );
  
  getIt.registerLazySingleton<SearchEmployees>(
    () => SearchEmployees(getIt<EmployeeRepository>()),
  );
  
  getIt.registerLazySingleton<AddEmployee>(
    () => AddEmployee(getIt<EmployeeRepository>()),
  );
  
  getIt.registerLazySingleton<UpdateEmployee>(
    () => UpdateEmployee(getIt<EmployeeRepository>()),
  );
  
  getIt.registerLazySingleton<DeleteEmployee>(
    () => DeleteEmployee(getIt<EmployeeRepository>()),
  );
  
  // Attendance Use Cases
  getIt.registerLazySingleton<GetAttendanceRecords>(
    () => GetAttendanceRecords(getIt<AttendanceRepository>()),
  );
  
  getIt.registerLazySingleton<GetAttendanceByEmployeeId>(
    () => GetAttendanceByEmployeeId(getIt<AttendanceRepository>()),
  );
  
  getIt.registerLazySingleton<MarkCheckIn>(
    () => MarkCheckIn(getIt<AttendanceRepository>()),
  );
  
  getIt.registerLazySingleton<MarkCheckOut>(
    () => MarkCheckOut(getIt<AttendanceRepository>()),
  );
  
  getIt.registerLazySingleton<GetMonthlyHours>(
    () => GetMonthlyHours(getIt<AttendanceRepository>()),
  );

  // ============================================
  // STEP 4: Register BLoCs
  // ============================================
  
  // EmployeeBloc - Using registerFactory because each screen might need its own instance
  // or we can use registerLazySingleton if we want to share the same bloc across screens
  getIt.registerFactory<EmployeeBloc>(
    () => EmployeeBloc(
      getEmployees: getIt<GetEmployees>(),
      searchEmployees: getIt<SearchEmployees>(),
      addEmployee: getIt<AddEmployee>(),
      updateEmployee: getIt<UpdateEmployee>(),
      deleteEmployee: getIt<DeleteEmployee>(),
    ),
  );
  
  // AttendanceBloc
  getIt.registerFactory<AttendanceBloc>(
    () => AttendanceBloc(
      getAttendanceRecords: getIt<GetAttendanceRecords>(),
      getAttendanceByEmployeeId: getIt<GetAttendanceByEmployeeId>(),
      markCheckIn: getIt<MarkCheckIn>(),
      markCheckOut: getIt<MarkCheckOut>(),
      getMonthlyHours: getIt<GetMonthlyHours>(),
    ),
  );
}

/// Dispose and clean up resources
void dispose() {
  // Close Realm if it's registered
  if (getIt.isRegistered<Realm>()) {
    getIt<Realm>().close();
  }
  
  // Reset GetIt (clears all registrations)
  // Only call this when you want to completely reset the app state
  // getIt.reset();
}
