# Code Examples

Practical examples showing how to work with the Clean Architecture.

## Example 1: Adding a New Employee

### Step 1: Create Employee Entity in Widget

```dart
// screens/employee_add_screen.dart
void _saveEmployee() {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  // Create entity
  final employee = Employee(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    name: _nameController.text,
    email: _emailController.text,
    position: _positionController.text,
    department: _selectedDepartment,
    joinDate: _joinDate,
    phone: _phoneController.text,
    salary: double.parse(_salaryController.text),
  );

  // Dispatch event to BLoC
  context.read<EmployeeBloc>().add(AddEmployee(employee));
}
```

### Step 2: BLoC Handles Event

```dart
// presentation/bloc/employee/employee_bloc.dart
Future<void> _onAddEmployee(
  AddEmployee event,
  Emitter<EmployeeState> emit,
) async {
  emit(const EmployeeOperationLoading());

  try {
    await addEmployeeUseCase(event.employee);
    emit(const EmployeeOperationSuccess('Employee added successfully'));

    // Reload list
    final employees = await getEmployeesUseCase();
    emit(EmployeeLoaded(
      employees: employees,
      filteredEmployees: employees,
    ));
  } catch (e) {
    emit(EmployeeError(e.toString()));
  }
}
```

### Step 3: Use Case Executes

```dart
// domain/usecases/employee/add_employee_usecase.dart
Future<void> call(Employee employee) async {
  return await repository.addEmployee(employee);
}
```

### Step 4: Repository Saves Data

```dart
// data/repositories/employee_repository_impl.dart
@override
Future<void> addEmployee(Employee employee) async {
  try {
    // Save to Firebase
    await firebaseRef.child(employee.id).set(EmployeeMapper.toMap(employee));

    // Cache to Realm
    realmDataSource.insert(EmployeeMapper.toRealm(employee));
  } catch (e) {
    // Still cache locally if Firebase fails
    realmDataSource.insert(EmployeeMapper.toRealm(employee));
    rethrow;
  }
}
```

## Example 2: Searching Employees

### Widget

```dart
// screens/employee_list_screen.dart
TextField(
  decoration: InputDecoration(
    hintText: 'Search employees...',
    prefixIcon: Icon(Icons.search),
  ),
  onChanged: (query) {
    // Dispatch search event
    context.read<EmployeeBloc>().add(SearchEmployees(query));
  },
)

// Display filtered results
BlocBuilder<EmployeeBloc, EmployeeState>(
  builder: (context, state) {
    if (state is EmployeeLoaded) {
      return ListView.builder(
        itemCount: state.filteredEmployees.length,
        itemBuilder: (context, index) {
          return EmployeeCard(state.filteredEmployees[index]);
        },
      );
    }
    return Container();
  },
)
```

### BLoC

```dart
// presentation/bloc/employee/employee_bloc.dart
Future<void> _onSearchEmployees(
  SearchEmployees event,
  Emitter<EmployeeState> emit,
) async {
  if (state is EmployeeLoaded) {
    final currentState = state as EmployeeLoaded;

    try {
      final filtered = await searchEmployeesUseCase(event.query);
      emit(currentState.copyWith(filteredEmployees: filtered));
    } catch (e) {
      emit(EmployeeError(e.toString()));
    }
  }
}
```

### Use Case

```dart
// domain/usecases/employee/search_employees_usecase.dart
Future<List<Employee>> call(String query) async {
  return await repository.searchEmployees(query);
}
```

### Repository

```dart
// data/repositories/employee_repository_impl.dart
@override
Future<List<Employee>> searchEmployees(String query) async {
  final employees = await getEmployees();
  
  if (query.isEmpty) {
    return employees;
  }
  
  final lowerQuery = query.toLowerCase();
  return employees.where((emp) {
    return emp.name.toLowerCase().contains(lowerQuery) ||
        emp.position.toLowerCase().contains(lowerQuery) ||
        emp.department.toLowerCase().contains(lowerQuery);
  }).toList();
}
```

## Example 3: Check In (Attendance)

### Widget

```dart
// screens/attendance_screen.dart
ElevatedButton.icon(
  onPressed: () {
    final selectedEmployee = state.employees.firstWhere(
      (e) => e.id == selectedEmployeeId,
    );
    
    context.read<AttendanceBloc>().add(
      CheckIn(selectedEmployee.id, selectedEmployee.name),
    );
  },
  icon: Icon(Icons.login),
  label: Text('Check In'),
)
```

### BLoC

```dart
// presentation/bloc/attendance/attendance_bloc.dart
Future<void> _onCheckIn(
  CheckIn event,
  Emitter<AttendanceState> emit,
) async {
  emit(const AttendanceOperationLoading());

  try {
    await checkInUseCase(event.employeeId, event.employeeName);
    emit(const AttendanceOperationSuccess('Checked in successfully'));

    // Reload attendance
    add(const LoadAttendance());
  } catch (e) {
    emit(AttendanceError(e.toString()));
  }
}
```

### Repository

```dart
// data/repositories/attendance_repository_impl.dart
@override
Future<void> checkIn(String employeeId, String employeeName) async {
  final now = DateTime.now();
  final dateKey = DateFormat('yyyy-MM-dd').format(now);
  final attendanceId = '${employeeId}_$dateKey';

  // Check if already checked in
  final existingRecord = await getTodayAttendance(employeeId);
  if (existingRecord != null && existingRecord.checkOutTime == null) {
    throw Exception('Already checked in today');
  }

  final attendanceData = {
    'employeeId': employeeId,
    'employeeName': employeeName,
    'date': now.toIso8601String(),
    'checkInTime': now.toIso8601String(),
    'checkOutTime': null,
    'totalHours': 0.0,
    'status': 'present',
  };

  await attendanceRef.child(attendanceId).set(attendanceData);
  
  realmDataSource.insert(AttendanceMapper.toRealm(Attendance(
    id: attendanceId,
    employeeId: employeeId,
    employeeName: employeeName,
    date: now,
    checkInTime: now,
    totalHours: 0.0,
    status: 'present',
  )));
}
```

## Example 4: Error Handling

### Repository Level

```dart
// data/repositories/employee_repository_impl.dart
@override
Future<List<Employee>> getEmployees() async {
  try {
    // Try Firebase first
    final snapshot = await firebaseRef.get();
    
    if (snapshot.exists) {
      // Parse and return
      return employees;
    } else {
      // Fallback to cache
      return _loadFromRealm();
    }
  } catch (e) {
    // If Firebase fails, try cache
    debugPrint('Firebase error: $e, loading from cache');
    return _loadFromRealm();
  }
}
```

### BLoC Level

```dart
// presentation/bloc/employee/employee_bloc.dart
Future<void> _onLoadEmployees(
  LoadEmployees event,
  Emitter<EmployeeState> emit,
) async {
  emit(const EmployeeLoading());

  try {
    final employees = await getEmployeesUseCase();
    emit(EmployeeLoaded(
      employees: employees,
      filteredEmployees: employees,
    ));
  } catch (e) {
    // Handle error
    emit(EmployeeError(e.toString()));
  }
}
```

### Widget Level

```dart
// screens/employee_list_screen.dart
BlocConsumer<EmployeeBloc, EmployeeState>(
  listener: (context, state) {
    if (state is EmployeeError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${state.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
  builder: (context, state) {
    if (state is EmployeeError) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.error),
            Text('Error: ${state.message}'),
            ElevatedButton(
              onPressed: () {
                context.read<EmployeeBloc>().add(const LoadEmployees());
              },
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    // ... other states
  },
)
```

## Example 5: Offline Support

### Repository with Caching

```dart
// data/repositories/employee_repository_impl.dart
@override
Future<List<Employee>> getEmployees() async {
  try {
    // Try Firebase first
    final snapshot = await firebaseRef.get();
    
    if (snapshot.exists) {
      final employees = parseEmployees(snapshot);
      
      // Cache to Realm
      realmDataSource.realm.write(() {
        realmDataSource.realm.deleteAll<EmployeeRealm>();
        for (var emp in employees) {
          realmDataSource.insert(EmployeeMapper.toRealm(emp));
        }
      });
      
      // Update sync time
      await syncRepository.setLastSyncTime('last_sync_employees', DateTime.now());
      
      return employees;
    } else {
      // No Firebase data, try cache
      return _loadFromRealm();
    }
  } catch (e) {
    // Firebase failed, use cache
    debugPrint('Firebase error: $e, loading from cache');
    final cached = _loadFromRealm();
    
    // Emit warning state (handled by BLoC)
    return cached;
  }
}

List<Employee> _loadFromRealm() {
  final realmData = realmDataSource.getAll();
  return realmData.map((emp) => EmployeeMapper.fromRealm(emp)).toList();
}
```

### Showing Offline Warning

```dart
// BLoC can set error message for offline mode
if (state is EmployeeLoaded && state.errorMessage != null) {
  return Container(
    padding: EdgeInsets.all(8),
    color: Colors.orange.shade100,
    child: Row(
      children: [
        Icon(Icons.warning, color: Colors.orange),
        SizedBox(width: 8),
        Text(state.errorMessage!),  // "Loaded from cache (offline)"
      ],
    ),
  );
}
```

## Example 6: Adding a New Feature

Let's say you want to add "Delete Multiple Employees" feature:

### Step 1: Add Event

```dart
// presentation/bloc/employee/employee_event.dart
class DeleteMultipleEmployees extends EmployeeEvent {
  final List<String> ids;
  
  const DeleteMultipleEmployees(this.ids);
  
  @override
  List<Object> get props => [ids];
}
```

### Step 2: Add Use Case

```dart
// domain/usecases/employee/delete_multiple_employees_usecase.dart
class DeleteMultipleEmployeesUseCase {
  final EmployeeRepository repository;
  
  DeleteMultipleEmployeesUseCase(this.repository);
  
  Future<void> call(List<String> ids) async {
    for (final id in ids) {
      await repository.deleteEmployee(id);
    }
  }
}
```

### Step 3: Add State (if needed)

```dart
// Already have EmployeeOperationSuccess, reuse it
```

### Step 4: Handle in BLoC

```dart
// presentation/bloc/employee/employee_bloc.dart
EmployeeBloc(...) : super(const EmployeeInitial()) {
  // ...
  on<DeleteMultipleEmployees>(_onDeleteMultipleEmployees);
}

Future<void> _onDeleteMultipleEmployees(
  DeleteMultipleEmployees event,
  Emitter<EmployeeState> emit,
) async {
  emit(const EmployeeOperationLoading());
  
  try {
    await deleteMultipleEmployeesUseCase(event.ids);
    emit(EmployeeOperationSuccess('${event.ids.length} employees deleted'));
    
    // Reload
    final employees = await getEmployeesUseCase();
    emit(EmployeeLoaded(employees: employees, filteredEmployees: employees));
  } catch (e) {
    emit(EmployeeError(e.toString()));
  }
}
```

### Step 5: Register in DI

```dart
// core/di/injection_container.dart
getIt.registerLazySingleton(() => DeleteMultipleEmployeesUseCase(getIt()));
```

### Step 6: Use in Widget

```dart
// screens/employee_list_screen.dart
IconButton(
  icon: Icon(Icons.delete),
  onPressed: () {
    final selectedIds = getSelectedEmployeeIds();
    context.read<EmployeeBloc>().add(
      DeleteMultipleEmployees(selectedIds),
    );
  },
)
```

## Key Takeaways

1. **Always follow the flow**: Widget → BLoC → Use Case → Repository → Data Source
2. **Handle errors at each layer**: Repository, BLoC, and Widget
3. **Use entities**: Always work with domain entities in business logic
4. **Cache for offline**: Always cache data for offline support
5. **Immutable states**: Never modify state directly

## Next Steps

- [Migration Guide](./07_MIGRATION_GUIDE.md) - See what changed from old code

