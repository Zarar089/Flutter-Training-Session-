# Data Flow

This document explains how data flows through the application layers.

## Overview

Data flows in a unidirectional manner:
```
User Action → Widget → BLoC → Use Case → Repository → Data Source
                ↑                                            ↓
                └────────────────────────────────────────────┘
                          (State flows back)
```

## Complete Flow Example: Loading Employees

### Step 1: User Opens Screen
```
User Action: Opens EmployeeListScreen
```

### Step 2: Widget Initializes BLoC
```dart
// main.dart
BlocProvider(
  create: (_) => di.getIt<EmployeeBloc>()..add(const LoadEmployees()),
)
```

### Step 3: BLoC Handles Event
```dart
// presentation/bloc/employee/employee_bloc.dart
on<LoadEmployees>(_onLoadEmployees);

Future<void> _onLoadEmployees(
  LoadEmployees event,
  Emitter<EmployeeState> emit,
) async {
  emit(const EmployeeLoading());  // 1. Emit loading state
  
  try {
    final employees = await getEmployeesUseCase();  // 2. Call use case
    emit(EmployeeLoaded(employees: employees));     // 3. Emit loaded state
  } catch (e) {
    emit(EmployeeError(e.toString()));              // 4. Emit error state
  }
}
```

### Step 4: Use Case Executes Business Logic
```dart
// domain/usecases/employee/get_employees_usecase.dart
class GetEmployeesUseCase {
  final EmployeeRepository repository;

  Future<List<Employee>> call() async {
    return await repository.getEmployees();  // Call repository
  }
}
```

### Step 5: Repository Implements Data Operations
```dart
// data/repositories/employee_repository_impl.dart
@override
Future<List<Employee>> getEmployees() async {
  try {
    // Try Firebase first
    final snapshot = await firebaseRef.get();
    
    if (snapshot.exists) {
      // Parse data and convert to entities
      final employees = data.entries.map((entry) {
        return EmployeeMapper.fromMap(entry.key, entry.value);
      }).toList();

      // Cache to Realm
      realmDataSource.write(() {
        for (var emp in employees) {
          realmDataSource.insert(EmployeeMapper.toRealm(emp));
        }
      });

      return employees;
    }
  } catch (e) {
    // Fallback to Realm cache
    return _loadFromRealm();
  }
}
```

### Step 6: State Flows Back to Widget
```dart
// screens/employee_list_screen.dart
BlocBuilder<EmployeeBloc, EmployeeState>(
  builder: (context, state) {
    if (state is EmployeeLoading) {
      return CircularProgressIndicator();
    }
    
    if (state is EmployeeLoaded) {
      return ListView.builder(
        itemCount: state.filteredEmployees.length,
        itemBuilder: (context, index) {
          return EmployeeCard(state.filteredEmployees[index]);
        },
      );
    }
    
    if (state is EmployeeError) {
      return ErrorWidget(state.message);
    }
    
    return Container();
  },
)
```

## Flow Diagram: Adding an Employee

```
┌──────────────────────────────────────────────────────────────┐
│ User Action: Taps "Add Employee" Button                      │
└───────────────────────┬──────────────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────────────────┐
│ Widget: employee_add_screen.dart                             │
│   - Validates form                                           │
│   - Creates Employee entity                                  │
│   - Dispatches AddEmployee event                             │
└───────────────────────┬──────────────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────────────────┐
│ BLoC: employee_bloc.dart                                     │
│   - Receives AddEmployee event                               │
│   - Emits EmployeeOperationLoading                           │
│   - Calls addEmployeeUseCase(employee)                       │
└───────────────────────┬──────────────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────────────────┐
│ Use Case: add_employee_usecase.dart                          │
│   - Executes business logic                                  │
│   - Calls repository.addEmployee(employee)                   │
└───────────────────────┬──────────────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────────────────┐
│ Repository: employee_repository_impl.dart                    │
│   - Converts Entity to Model (via Mapper)                    │
│   - Saves to Firebase                                        │
│   - Caches to Realm                                          │
│   - Updates sync timestamp                                   │
└───────────────────────┬──────────────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────────────────┐
│ Data Sources:                                                │
│   - firebase_database.dart: Saves to Firebase                │
│   - realm_db.dart: Caches to local database                  │
│   - shared_preferences: Updates sync time                    │
└───────────────────────┬──────────────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────────────────┐
│ Success! State flows back:                                   │
│   Repository → Use Case → BLoC → Widget                      │
│   BLoC emits EmployeeOperationSuccess                        │
│   Widget shows success message                               │
└──────────────────────────────────────────────────────────────┘
```

## Error Handling Flow

```
Repository throws error
        │
        ▼
Use Case propagates error
        │
        ▼
BLoC catches error
        │
        ▼
BLoC emits EmployeeError state
        │
        ▼
Widget displays error message
```

Example:
```dart
// Repository
Future<void> addEmployee(Employee employee) async {
  try {
    await firebaseRef.set(...);
  } catch (e) {
    // Still cache locally
    realmDataSource.insert(...);
    rethrow;  // Propagate error
  }
}

// BLoC
try {
  await addEmployeeUseCase(employee);
  emit(EmployeeOperationSuccess());
} catch (e) {
  emit(EmployeeError(e.toString()));  // Widget shows this
}
```

## Offline Support Flow

```
1. Try Firebase
        │
        ├─ Success ──> Cache to Realm ──> Return data
        │
        └─ Fail ──> Load from Realm cache ──> Return data
```

This ensures the app works even when offline!

## State Management Flow

### Event-Driven Architecture

```
User Action → Event → BLoC Handler → Use Case → Repository
                                             ↓
State ←──────────────────────────────────────┘
  ↓
Widget Rebuilds
```

### Example: Search Employees

```dart
// 1. User types in search field
TextField(
  onChanged: (query) {
    context.read<EmployeeBloc>().add(SearchEmployees(query));
  },
)

// 2. BLoC handles search
on<SearchEmployees>(_onSearchEmployees);

Future<void> _onSearchEmployees(
  SearchEmployees event,
  Emitter<EmployeeState> emit,
) async {
  final currentState = state as EmployeeLoaded;
  final filtered = await searchEmployeesUseCase(event.query);
  
  emit(currentState.copyWith(filteredEmployees: filtered));
}

// 3. Widget rebuilds with filtered list
BlocBuilder<EmployeeBloc, EmployeeState>(
  builder: (context, state) {
    final employees = (state as EmployeeLoaded).filteredEmployees;
    return ListView(...);  // Shows filtered results
  },
)
```

## Key Takeaways

1. **Unidirectional Flow**: Data always flows in one direction
2. **State-Based UI**: Widgets react to state changes, not direct data
3. **Error Handling**: Errors bubble up and are handled at BLoC level
4. **Offline Support**: Repository handles fallback to cache
5. **Separation**: Each layer has clear responsibilities

## Next Steps

- [BLoC Pattern](./04_BLOC_PATTERN.md) - Deep dive into state management
- [Code Examples](./06_CODE_EXAMPLES.md) - See practical examples

