# Migration Guide

This document explains what changed when migrating from spaghetti code to Clean Architecture.

## Before vs After Comparison

### Employee List Screen

#### ❌ Before (Spaghetti Code)

```dart
class _EmployeeListScreenState extends State<EmployeeListScreen> {
  // Direct dependencies - BAD!
  final DatabaseReference _firebaseRef = FirebaseDatabase.instance.ref('employees');
  late Realm _realm;
  
  // State mixed with UI
  List<Map<String, dynamic>> employees = [];
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _initRealm();      // Direct database access
    _loadEmployees();  // Business logic in widget
  }
  
  // Business logic in widget - BAD!
  Future<void> _loadEmployees() async {
    setState(() => isLoading = true);
    
    try {
      final snapshot = await _firebaseRef.get();
      // Parse data directly
      // Save to Realm directly
      // Update UI directly
    } catch (e) {
      // Error handling in widget
    }
    
    setState(() => isLoading = false);
  }
  
  // More business logic...
  void _searchEmployees(String query) { /* ... */ }
  Future<void> _deleteEmployee(String id) { /* ... */ }
}
```

**Problems:**
- Direct database access in UI
- Business logic in widgets
- Hard to test
- Tight coupling
- No separation of concerns

#### ✅ After (Clean Architecture)

```dart
class EmployeeListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<EmployeeBloc, EmployeeState>(
        builder: (context, state) {
          // Pure UI - just displays state
          if (state is EmployeeLoading) {
            return CircularProgressIndicator();
          }
          
          if (state is EmployeeLoaded) {
            return ListView.builder(
              itemCount: state.employees.length,
              itemBuilder: (context, index) {
                return EmployeeCard(state.employees[index]);
              },
            );
          }
          
          return Container();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Just dispatch event - no business logic!
          context.read<EmployeeBloc>().add(const LoadEmployees());
        },
      ),
    );
  }
}
```

**Benefits:**
- Pure UI widget
- No business logic
- Easy to test
- Loose coupling
- Clear separation

### Adding Employee

#### ❌ Before

```dart
Future<void> _saveEmployee() async {
  setState(() => isLoading = true);
  
  try {
    // Direct Firebase access
    await _firebaseRef.child(employeeId).set(employeeData);
    
    // Direct Realm access
    _realm.write(() {
      _realm.add(EmployeeRealm(...));
    });
    
    // UI logic mixed with business logic
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(...);
  } catch (e) {
    // Error handling in widget
  }
  
  setState(() => isLoading = false);
}
```

#### ✅ After

```dart
void _saveEmployee() {
  final employee = Employee(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    name: _nameController.text,
    // ... other fields
  );
  
  // Just dispatch event
  context.read<EmployeeBloc>().add(AddEmployee(employee));
}

// BLoC handles everything
BlocListener<EmployeeBloc, EmployeeState>(
  listener: (context, state) {
    if (state is EmployeeOperationSuccess) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(...);
    }
  },
  child: YourWidget(),
)
```

## Architecture Changes

### File Structure

#### Before

```
lib/
├── screens/
│   ├── employee_list_screen.dart (UI + Logic + Data)
│   ├── employee_add_screen.dart (UI + Logic + Data)
│   └── ...
├── data/
│   └── models/
└── main.dart
```

#### After

```
lib/
├── screens/ (Pure UI)
├── presentation/bloc/ (State Management)
├── domain/ (Business Logic)
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── data/ (Data Implementation)
│   ├── repositories/
│   ├── data_source/
│   └── mappers/
└── core/di/ (Dependency Injection)
```

## Key Changes

### 1. State Management

**Before:** `setState()` directly in widgets

**After:** BLoC pattern with events and states

### 2. Data Access

**Before:** Direct access to Firebase/Realm in widgets

**After:** Access through Repository pattern

### 3. Business Logic

**Before:** Logic scattered in widgets

**After:** Logic in Use Cases and BLoC

### 4. Dependencies

**Before:** Classes create their own dependencies

**After:** Dependencies injected via GetIt

### 5. Error Handling

**Before:** try-catch in widgets

**After:** Errors handled at Repository/BLoC level, states propagate to UI

## Migration Checklist

- [x] Create folder structure
- [x] Move entities to domain layer
- [x] Create repository interfaces
- [x] Implement repositories
- [x] Create use cases
- [x] Create BLoC for state management
- [x] Refactor widgets to use BLoC
- [x] Set up dependency injection
- [x] Remove business logic from widgets
- [x] Test all functionality still works

## Code Patterns Migration

### Loading Data

#### Before

```dart
Future<void> _loadData() async {
  setState(() => isLoading = true);
  final data = await someAsyncOperation();
  setState(() {
    isLoading = false;
    this.data = data;
  });
}
```

#### After

```dart
// Widget
BlocProvider(
  create: (_) => bloc..add(LoadData()),
)

// BLoC
on<LoadData>(_onLoadData);
Future<void> _onLoadData(...) async {
  emit(Loading());
  final data = await useCase();
  emit(Loaded(data));
}
```

### Error Handling

#### Before

```dart
try {
  await operation();
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e.toString())),
  );
}
```

#### After

```dart
// BLoC
try {
  await useCase();
  emit(Success());
} catch (e) {
  emit(Error(e.toString()));
}

// Widget
BlocListener(
  listener: (context, state) {
    if (state is Error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
)
```

### Data Access

#### Before

```dart
final snapshot = await FirebaseDatabase.instance.ref('employees').get();
final data = snapshot.value as Map;
// Parse data...
```

#### After

```dart
// Widget
final employees = await repository.getEmployees();

// Repository handles Firebase/Realm internally
```

## Benefits Achieved

✅ **Separation of Concerns**: Each layer has clear responsibility
✅ **Testability**: Each layer can be tested independently
✅ **Maintainability**: Changes in one layer don't affect others
✅ **Scalability**: Easy to add new features
✅ **Readability**: Clear structure and code organization
✅ **Flexibility**: Can change data sources without rewriting business logic

## Common Mistakes to Avoid

### ❌ Don't: Access repositories directly in widgets

```dart
// BAD
final repository = di.getIt<EmployeeRepository>();
final employees = await repository.getEmployees();
```

### ✅ Do: Use BLoC

```dart
// GOOD
context.read<EmployeeBloc>().add(const LoadEmployees());
```

### ❌ Don't: Put business logic in widgets

```dart
// BAD
void _saveEmployee() {
  final id = DateTime.now().millisecondsSinceEpoch.toString();
  // Business logic...
}
```

### ✅ Do: Create use case

```dart
// GOOD
void _saveEmployee() {
  final employee = Employee(...);
  context.read<EmployeeBloc>().add(AddEmployee(employee));
}
```

### ❌ Don't: Use Map<String, dynamic> for entities

```dart
// BAD
List<Map<String, dynamic>> employees = [];
```

### ✅ Do: Use domain entities

```dart
// GOOD
List<Employee> employees = [];
```

## Testing Improvements

### Before: Hard to test

```dart
// Widget with business logic - hard to test
class EmployeeListScreen extends StatefulWidget {
  // Can't easily mock Firebase/Realm
}
```

### After: Easy to test

```dart
// Test BLoC
test('should load employees', () {
  when(mockRepository.getEmployees()).thenAnswer((_) async => employees);
  
  bloc.add(const LoadEmployees());
  
  expect(bloc.state, isA<EmployeeLoaded>());
});

// Test Use Case
test('should add employee', () {
  when(mockRepository.addEmployee(employee)).thenAnswer((_) async => {});
  
  await useCase(employee);
  
  verify(mockRepository.addEmployee(employee)).called(1);
});

// Test Repository
test('should cache employees to Realm', () {
  await repository.addEmployee(employee);
  
  verify(mockRealm.insert(any)).called(1);
});
```

## Summary

The migration from spaghetti code to Clean Architecture:

1. **Separated** UI, business logic, and data layers
2. **Introduced** BLoC for state management
3. **Created** use cases for business operations
4. **Implemented** repository pattern for data access
5. **Set up** dependency injection for loose coupling
6. **Made** code testable and maintainable

The app now follows Clean Architecture principles, making it:
- Easier to understand
- Easier to test
- Easier to maintain
- Easier to extend

