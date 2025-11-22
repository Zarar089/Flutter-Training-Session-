import 'package:get_it/get_it.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:realm/realm.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Data Sources
import '../../data/data_source/remote_data_source/firebase_data_source.dart';
import '../../data/data_source/local_data_source/realm_db.dart';
import '../../data/data_source/local_data_source/shared_preference_data_source.dart';

// Repositories
import '../../data/repositories/employee_repository_impl.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../data/repositories/sync_repository_impl.dart';

// Domain Repositories (interfaces)
import '../../domain/repositories/employee_repository.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/repositories/sync_repository.dart';

// Use Cases
import '../../domain/usecases/employee/get_employees_usecase.dart';
import '../../domain/usecases/employee/add_employee_usecase.dart';
import '../../domain/usecases/employee/update_employee_usecase.dart';
import '../../domain/usecases/employee/delete_employee_usecase.dart';
import '../../domain/usecases/employee/search_employees_usecase.dart';
import '../../domain/usecases/employee/get_employee_by_id_usecase.dart';
import '../../domain/usecases/attendance/get_attendance_records_usecase.dart';
import '../../domain/usecases/attendance/check_in_usecase.dart';
import '../../domain/usecases/attendance/check_out_usecase.dart';
import '../../domain/usecases/attendance/calculate_monthly_hours_usecase.dart';
import '../../domain/usecases/sync/get_last_sync_usecase.dart';
import '../../domain/usecases/sync/set_last_sync_usecase.dart';

// BLoC
import '../../presentation/bloc/employee/employee_bloc.dart';
import '../../presentation/bloc/attendance/attendance_bloc.dart';

// Models
import '../../data/models/realm_mdoels/employee_model.dart';
import '../../attendance_model.dart' as realm_model;

final getIt = GetIt.instance;

Future<void> init() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);

  // Realm Configuration
  final realmConfig = Configuration.local([
    EmployeeRealm.schema,
    realm_model.Attendance.schema,
  ]);
  final realm = Realm(realmConfig);
  getIt.registerLazySingleton(() => realm);

  // Firebase
  final firebaseDatabase = FirebaseDatabase.instance;
  getIt.registerLazySingleton(() => firebaseDatabase);

  final employeesRef = firebaseDatabase.ref('employees');
  final attendanceRef = firebaseDatabase.ref('attendance');

  getIt.registerLazySingleton(() => employeesRef);
  getIt.registerLazySingleton<DatabaseReference>(
    () => attendanceRef,
    instanceName: 'attendance',
  );

  // Data Sources
  getIt.registerLazySingleton(
      () => SharedPreferenceDataSource(getIt<SharedPreferences>()));

  getIt.registerLazySingleton(() =>
      FirebaseDataSource<Map<String, dynamic>>(getIt<DatabaseReference>()));

  getIt.registerLazySingleton(
      () => RealmDataSource<EmployeeRealm>(getIt<Realm>()));
  getIt.registerLazySingleton<RealmDataSource<realm_model.Attendance>>(
    () => RealmDataSource<realm_model.Attendance>(getIt<Realm>()),
    instanceName: 'attendance',
  );

  // Repositories
  getIt.registerLazySingleton<SyncRepository>(
    () => SyncRepositoryImpl(getIt<SharedPreferenceDataSource>()),
  );

  getIt.registerLazySingleton<EmployeeRepository>(
    () => EmployeeRepositoryImpl(
      firebaseDataSource: getIt<FirebaseDataSource<Map<String, dynamic>>>(),
      realmDataSource: getIt<RealmDataSource<EmployeeRealm>>(),
      syncRepository: getIt<SyncRepository>(),
      firebaseRef: getIt<DatabaseReference>(),
    ),
  );

  getIt.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(
      attendanceRef: getIt<DatabaseReference>(instanceName: 'attendance'),
      realmDataSource: getIt<RealmDataSource<realm_model.Attendance>>(
        instanceName: 'attendance',
      ),
    ),
  );

  // Use Cases - Employee
  getIt.registerLazySingleton(
      () => GetEmployeesUseCase(getIt<EmployeeRepository>()));
  getIt.registerLazySingleton(
      () => AddEmployeeUseCase(getIt<EmployeeRepository>()));
  getIt.registerLazySingleton(
      () => UpdateEmployeeUseCase(getIt<EmployeeRepository>()));
  getIt.registerLazySingleton(
      () => DeleteEmployeeUseCase(getIt<EmployeeRepository>()));
  getIt.registerLazySingleton(
      () => SearchEmployeesUseCase(getIt<EmployeeRepository>()));
  getIt.registerLazySingleton(
      () => GetEmployeeByIdUseCase(getIt<EmployeeRepository>()));

  // Use Cases - Attendance
  getIt.registerLazySingleton(
      () => GetAttendanceRecordsUseCase(getIt<AttendanceRepository>()));
  getIt.registerLazySingleton(
      () => CheckInUseCase(getIt<AttendanceRepository>()));
  getIt.registerLazySingleton(
      () => CheckOutUseCase(getIt<AttendanceRepository>()));
  getIt.registerLazySingleton(
      () => CalculateMonthlyHoursUseCase(getIt<AttendanceRepository>()));

  // Use Cases - Sync
  getIt
      .registerLazySingleton(() => GetLastSyncUseCase(getIt<SyncRepository>()));
  getIt
      .registerLazySingleton(() => SetLastSyncUseCase(getIt<SyncRepository>()));

  // BLoC
  getIt.registerFactory(
    () => EmployeeBloc(
      getEmployeesUseCase: getIt<GetEmployeesUseCase>(),
      addEmployeeUseCase: getIt<AddEmployeeUseCase>(),
      updateEmployeeUseCase: getIt<UpdateEmployeeUseCase>(),
      deleteEmployeeUseCase: getIt<DeleteEmployeeUseCase>(),
      searchEmployeesUseCase: getIt<SearchEmployeesUseCase>(),
    ),
  );

  getIt.registerFactory(
    () => AttendanceBloc(
      getAttendanceRecordsUseCase: getIt<GetAttendanceRecordsUseCase>(),
      checkInUseCase: getIt<CheckInUseCase>(),
      checkOutUseCase: getIt<CheckOutUseCase>(),
      calculateMonthlyHoursUseCase: getIt<CalculateMonthlyHoursUseCase>(),
      getEmployeesUseCase: getIt<GetEmployeesUseCase>(),
    ),
  );
}
