# Dependency Injection with GetIt

Dependency Injection (DI) is a design pattern that provides dependencies to classes rather than having them create dependencies themselves.

## Why Dependency Injection?

### Without DI (Tight Coupling)

```dart
class EmployeeBloc {
  // Creates dependencies itself - BAD!
  final repository = EmployeeRepositoryImpl(
    firebaseDataSource: FirebaseDataSource(...),
    realmDataSource: RealmDataSource(...),
    // ... many dependencies
  );
}
```

**Problems:**
- Hard to test (can't mock dependencies)
- Tight coupling
- Difficult to change implementations

### With DI (Loose Coupling)

```dart
class EmployeeBloc {
  // Dependencies injected - GOOD!
  final GetEmployeesUseCase getEmployeesUseCase;
  
  EmployeeBloc({
    required this.getEmployeesUseCase,  // Injected!
  });
}
```

**Benefits:**
- Easy to test (can inject mocks)
- Loose coupling
- Easy to swap implementations

## GetIt Setup

GetIt is a service locator for dependency injection in Flutter.

### Initialization (`core/di/injection_container.dart`)

```dart
final getIt = GetIt.instance;

Future<void> init() async {
  // 1. External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);

  // 2. Data Sources
  getIt.registerLazySingleton(() => SharedPreferenceDataSource(getIt()));
  
  // 3. Repositories
  getIt.registerLazySingleton<EmployeeRepository>(
    () => EmployeeRepositoryImpl(
      firebaseDataSource: getIt(),
      realmDataSource: getIt(),
      syncRepository: getIt(),
      firebaseRef: getIt(),
    ),
  );

  // 4. Use Cases
  getIt.registerLazySingleton(() => GetEmployeesUseCase(getIt()));
  getIt.registerLazySingleton(() => AddEmployeeUseCase(getIt()));

  // 5. BLoC (Factory - creates new instance each time)
  getIt.registerFactory(
    () => EmployeeBloc(
      getEmployeesUseCase: getIt(),
      addEmployeeUseCase: getIt(),
      // ...
    ),
  );
}
```

### Registration Types

1. **registerLazySingleton**: Creates once, reuses same instance
   ```dart
   getIt.registerLazySingleton(() => SharedPreferences.getInstance());
   ```
   - Use for: Repositories, Use Cases, Data Sources
   - Memory efficient

2. **registerFactory**: Creates new instance each time
   ```dart
   getIt.registerFactory(() => EmployeeBloc(...));
   ```
   - Use for: BLoC (each screen needs its own instance)
   - Fresh instance every time

3. **registerSingleton**: Creates immediately
   ```dart
   getIt.registerSingleton(MyClass());
   ```
   - Use for: App-wide singletons

## Dependency Graph

```
BLoC (Factory)
  └─> Use Cases (LazySingleton)
        └─> Repository (LazySingleton)
              └─> Data Sources (LazySingleton)
                    └─> External Dependencies
```

## Usage in main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Dependency Injection
  await di.init();
  
  runApp(const EmployeeApp());
}

class EmployeeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.getIt<EmployeeBloc>()..add(const LoadEmployees()),
        ),
        BlocProvider(
          create: (_) => di.getIt<AttendanceBloc>()
            ..add(const LoadEmployees())
            ..add(const LoadAttendance()),
        ),
      ],
      child: MaterialApp(...),
    );
  }
}
```

## Accessing Dependencies

### Getting from GetIt

```dart
// Get registered dependency
final employeeBloc = di.getIt<EmployeeBloc>();

// Get with parameter (if registered)
final repository = di.getIt<EmployeeRepository>();
```

### In Widgets (Recommended)

```dart
// Use context.read<BLoC>() - provided by flutter_bloc
context.read<EmployeeBloc>().add(LoadEmployees());

// Or access directly from GetIt
final bloc = di.getIt<EmployeeBloc>();
```

## Dependency Registration Order

**Important:** Register dependencies in order of dependency:

```dart
// 1. External dependencies first
final sharedPreferences = await SharedPreferences.getInstance();
getIt.registerLazySingleton(() => sharedPreferences);

// 2. Then data sources (depend on externals)
getIt.registerLazySingleton(() => SharedPreferenceDataSource(getIt()));

// 3. Then repositories (depend on data sources)
getIt.registerLazySingleton<EmployeeRepository>(
  () => EmployeeRepositoryImpl(...),
);

// 4. Then use cases (depend on repositories)
getIt.registerLazySingleton(() => GetEmployeesUseCase(getIt()));

// 5. Finally BLoC (depends on use cases)
getIt.registerFactory(() => EmployeeBloc(...));
```

## Testing with DI

### Mock Dependencies

```dart
// In test file
class MockEmployeeRepository extends Mock implements EmployeeRepository {}

void main() {
  late MockEmployeeRepository mockRepository;
  
  setUp(() {
    mockRepository = MockEmployeeRepository();
    
    // Register mock instead of real implementation
    getIt.registerLazySingleton<EmployeeRepository>(
      () => mockRepository,
    );
  });
  
  tearDown(() {
    getIt.reset();  // Clean up
  });
  
  test('should load employees', () async {
    // Arrange
    when(mockRepository.getEmployees()).thenAnswer((_) async => employees);
    
    // Act
    final bloc = EmployeeBloc(getEmployeesUseCase: getIt());
    bloc.add(const LoadEmployees());
    
    // Assert
    expect(bloc.state, isA<EmployeeLoaded>());
  });
}
```

## Named Instances

Sometimes you need multiple instances of the same type:

```dart
// Register with name
getIt.registerLazySingleton<DatabaseReference>(
  () => firebaseDatabase.ref('employees'),
  instanceName: 'employees',
);

getIt.registerLazySingleton<DatabaseReference>(
  () => firebaseDatabase.ref('attendance'),
  instanceName: 'attendance',
);

// Get with name
final employeesRef = getIt<DatabaseReference>(instanceName: 'employees');
final attendanceRef = getIt<DatabaseReference>(instanceName: 'attendance');
```

## Complete Registration Example

```dart
Future<void> init() async {
  // ==========================================
  // 1. EXTERNAL DEPENDENCIES
  // ==========================================
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);

  final realmConfig = Configuration.local([EmployeeRealm.schema, ...]);
  final realm = Realm(realmConfig);
  getIt.registerLazySingleton(() => realm);

  final firebaseDatabase = FirebaseDatabase.instance;
  getIt.registerLazySingleton(() => firebaseDatabase);
  
  final employeesRef = firebaseDatabase.ref('employees');
  getIt.registerLazySingleton(() => employeesRef);
  
  final attendanceRef = firebaseDatabase.ref('attendance');
  getIt.registerLazySingleton<DatabaseReference>(
    () => attendanceRef,
    instanceName: 'attendance',
  );

  // ==========================================
  // 2. DATA SOURCES
  // ==========================================
  getIt.registerLazySingleton(() => SharedPreferenceDataSource(getIt()));
  getIt.registerLazySingleton(() => FirebaseDataSource<Map<String, dynamic>>(getIt()));
  getIt.registerLazySingleton(() => RealmDataSource<EmployeeRealm>(getIt()));
  getIt.registerLazySingleton<RealmDataSource<Attendance>>(
    () => RealmDataSource<Attendance>(getIt()),
    instanceName: 'attendance',
  );

  // ==========================================
  // 3. REPOSITORIES
  // ==========================================
  getIt.registerLazySingleton<SyncRepository>(
    () => SyncRepositoryImpl(getIt()),
  );

  getIt.registerLazySingleton<EmployeeRepository>(
    () => EmployeeRepositoryImpl(
      firebaseDataSource: getIt(),
      realmDataSource: getIt(),
      syncRepository: getIt(),
      firebaseRef: getIt(),
    ),
  );

  getIt.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(
      attendanceRef: getIt<DatabaseReference>(instanceName: 'attendance'),
      realmDataSource: getIt<RealmDataSource<Attendance>>(
        instanceName: 'attendance',
      ),
    ),
  );

  // ==========================================
  // 4. USE CASES
  // ==========================================
  getIt.registerLazySingleton(() => GetEmployeesUseCase(getIt()));
  getIt.registerLazySingleton(() => AddEmployeeUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateEmployeeUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteEmployeeUseCase(getIt()));
  getIt.registerLazySingleton(() => SearchEmployeesUseCase(getIt()));
  getIt.registerLazySingleton(() => GetEmployeeByIdUseCase(getIt()));

  getIt.registerLazySingleton(() => GetAttendanceRecordsUseCase(getIt()));
  getIt.registerLazySingleton(() => CheckInUseCase(getIt()));
  getIt.registerLazySingleton(() => CheckOutUseCase(getIt()));
  getIt.registerLazySingleton(() => CalculateMonthlyHoursUseCase(getIt()));

  // ==========================================
  // 5. BLoC (FACTORY)
  // ==========================================
  getIt.registerFactory(
    () => EmployeeBloc(
      getEmployeesUseCase: getIt(),
      addEmployeeUseCase: getIt(),
      updateEmployeeUseCase: getIt(),
      deleteEmployeeUseCase: getIt(),
      searchEmployeesUseCase: getIt(),
    ),
  );

  getIt.registerFactory(
    () => AttendanceBloc(
      getAttendanceRecordsUseCase: getIt(),
      checkInUseCase: getIt(),
      checkOutUseCase: getIt(),
      calculateMonthlyHoursUseCase: getIt(),
      getEmployeesUseCase: getIt(),
    ),
  );
}
```

## Benefits Summary

✅ **Testability**: Easy to inject mocks for testing
✅ **Maintainability**: All dependencies in one place
✅ **Flexibility**: Easy to swap implementations
✅ **Loose Coupling**: Classes don't create their dependencies
✅ **Single Responsibility**: DI container handles wiring

## Next Steps

- [Code Examples](./06_CODE_EXAMPLES.md) - See how everything works together
- [Migration Guide](./07_MIGRATION_GUIDE.md) - What changed from old code

