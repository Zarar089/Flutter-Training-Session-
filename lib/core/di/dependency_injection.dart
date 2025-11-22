import 'package:employee_app_v1_spaghetti/data/data_source/local_data_source/realm_db.dart';
import 'package:employee_app_v1_spaghetti/data/data_source/local_storage/shared_pref.dart';
import 'package:employee_app_v1_spaghetti/data/data_source/remote_data_source/firebase_data_source.dart';
import 'package:employee_app_v1_spaghetti/data/models/realm_mdoels/employee_model.dart';
import 'package:employee_app_v1_spaghetti/data/repositories/employee_repository_impl.dart';
import 'package:employee_app_v1_spaghetti/domain/entities/employee.dart';
import 'package:employee_app_v1_spaghetti/domain/repositories/i_employee_repository.dart';
import 'package:employee_app_v1_spaghetti/domain/use_cases/employee_usecase.dart';
import 'package:employee_app_v1_spaghetti/presentations/screens/blocs/employee_add/employee_add_bloc.dart';
import 'package:employee_app_v1_spaghetti/presentations/screens/blocs/employee_detail/employee_detail_bloc.dart';
import 'package:employee_app_v1_spaghetti/presentations/screens/blocs/employee_list/employee_list_bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get_it/get_it.dart';
import 'package:realm/realm.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // Shared Preferences Helper
  final sharedPrefsHelper = SharedPreferencesHelper();
  await sharedPrefsHelper.create();
  getIt.registerSingleton<SharedPreferencesHelper>(sharedPrefsHelper);

  // Realm
  final config = Configuration.local([EmployeeRealm.schema]);
  final realm = Realm(config);
  getIt.registerSingleton<Realm>(realm);

  // Firebase Database Reference
  final firebaseRef = FirebaseDatabase.instance.ref('employees');
  getIt.registerSingleton<DatabaseReference>(firebaseRef);

  // Data Sources
  getIt.registerLazySingleton<FirebaseDataSource<Employee>>(
    () => FirebaseDataSource<Employee>(getIt<DatabaseReference>()),
  );

  getIt.registerLazySingleton<RealmDataSource<EmployeeRealm>>(
    () => RealmDataSource<EmployeeRealm>(getIt<Realm>()),
  );

  // Repository
  getIt.registerLazySingleton<IEmployeeRepository>(
    () => EmployeeRepositoryImpl(
      firebaseDataSource: getIt<FirebaseDataSource<Employee>>(),
      realmDataSource: getIt<RealmDataSource<EmployeeRealm>>(),
      sharedPreferencesHelper: getIt<SharedPreferencesHelper>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton<EmployeeUseCase>(
    () => EmployeeUseCase(getIt<IEmployeeRepository>()),
  );

  // BLoCs - Factory registration for multiple instances
  getIt.registerFactory<EmployeeListBloc>(
    () => EmployeeListBloc(getIt<EmployeeUseCase>()),
  );

  getIt.registerFactory<EmployeeDetailBloc>(
    () => EmployeeDetailBloc(getIt<EmployeeUseCase>()),
  );

  getIt.registerFactory<EmployeeAddBloc>(
    () => EmployeeAddBloc(getIt<EmployeeUseCase>()),
  );
}
