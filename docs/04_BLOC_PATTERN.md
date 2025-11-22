# BLoC Pattern

BLoC (Business Logic Component) is a state management pattern that separates business logic from UI.

## Why BLoC?

✅ **Benefits:**
- Business logic separate from UI
- Easy to test
- Predictable state management
- Works well with Clean Architecture

## BLoC Components

Every BLoC has three parts:

1. **Events**: What can happen (user actions)
2. **States**: Current condition of the app
3. **Bloc**: Logic that converts events to states

## Employee BLoC Example

### Events (`employee_event.dart`)

Events represent user actions:

```dart
abstract class EmployeeEvent extends Equatable {
  const EmployeeEvent();
}

class LoadEmployees extends EmployeeEvent {
  const LoadEmployees();
}

class AddEmployee extends EmployeeEvent {
  final Employee employee;
  const AddEmployee(this.employee);
}

class DeleteEmployee extends EmployeeEvent {
  final String id;
  const DeleteEmployee(this.id);
}

class SearchEmployees extends EmployeeEvent {
  final String query;
  const SearchEmployees(this.query);
}
```

### States (`employee_state.dart`)

States represent the UI condition:

```dart
abstract class EmployeeState extends Equatable {
  const EmployeeState();
}

class EmployeeInitial extends EmployeeState {}

class EmployeeLoading extends EmployeeState {}

class EmployeeLoaded extends EmployeeState {
  final List<Employee> employees;
  final List<Employee> filteredEmployees;
  
  const EmployeeLoaded({
    required this.employees,
    required this.filteredEmployees,
  });
}

class EmployeeError extends EmployeeState {
  final String message;
  const EmployeeError(this.message);
}

class EmployeeOperationSuccess extends EmployeeState {
  final String message;
  const EmployeeOperationSuccess(this.message);
}
```

### BLoC (`employee_bloc.dart`)

BLoC handles events and emits states:

```dart
class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final GetEmployeesUseCase getEmployeesUseCase;
  final AddEmployeeUseCase addEmployeeUseCase;
  // ... other use cases

  EmployeeBloc({
    required this.getEmployeesUseCase,
    required this.addEmployeeUseCase,
    // ...
  }) : super(const EmployeeInitial()) {
    // Register event handlers
    on<LoadEmployees>(_onLoadEmployees);
    on<AddEmployee>(_onAddEmployee);
    on<DeleteEmployee>(_onDeleteEmployee);
    on<SearchEmployees>(_onSearchEmployees);
  }

  // Event handler
  Future<void> _onLoadEmployees(
    LoadEmployees event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(const EmployeeLoading());  // Show loading

    try {
      final employees = await getEmployeesUseCase();
      emit(EmployeeLoaded(                    // Show data
        employees: employees,
        filteredEmployees: employees,
      ));
    } catch (e) {
      emit(EmployeeError(e.toString()));      // Show error
    }
  }

  // Other handlers...
}
```

## Using BLoC in Widgets

### Providing BLoC

```dart
// In main.dart or parent widget
BlocProvider(
  create: (_) => di.getIt<EmployeeBloc>()..add(const LoadEmployees()),
  child: EmployeeListScreen(),
)
```

### Listening to Events

```dart
// Dispatch an event
context.read<EmployeeBloc>().add(const LoadEmployees());
context.read<EmployeeBloc>().add(AddEmployee(employee));
context.read<EmployeeBloc>().add(DeleteEmployee(employeeId));
```

### Reacting to States

#### BlocBuilder (Rebuilds UI)

```dart
BlocBuilder<EmployeeBloc, EmployeeState>(
  builder: (context, state) {
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
    
    if (state is EmployeeError) {
      return Text('Error: ${state.message}');
    }
    
    return Container();
  },
)
```

#### BlocListener (Side effects like showing snackbar)

```dart
BlocListener<EmployeeBloc, EmployeeState>(
  listener: (context, state) {
    if (state is EmployeeOperationSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
    
    if (state is EmployeeError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${state.message}')),
      );
    }
  },
  child: YourWidget(),
)
```

#### BlocConsumer (Both Builder + Listener)

```dart
BlocConsumer<EmployeeBloc, EmployeeState>(
  listener: (context, state) {
    // Handle side effects (snackbars, navigation)
    if (state is EmployeeOperationSuccess) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  builder: (context, state) {
    // Build UI based on state
    if (state is EmployeeLoading) {
      return CircularProgressIndicator();
    }
    
    if (state is EmployeeLoaded) {
      return EmployeeList(state.employees);
    }
    
    return Container();
  },
)
```

## Complete Example: Add Employee Flow

### 1. User fills form and taps "Save"

```dart
// employee_add_screen.dart
ElevatedButton(
  onPressed: () {
    final employee = Employee(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      email: _emailController.text,
      // ... other fields
    );
    
    // Dispatch event
    context.read<EmployeeBloc>().add(AddEmployee(employee));
  },
  child: Text('Save'),
)
```

### 2. BLoC handles the event

```dart
// employee_bloc.dart
Future<void> _onAddEmployee(
  AddEmployee event,
  Emitter<EmployeeState> emit,
) async {
  emit(const EmployeeOperationLoading());  // Show loading

  try {
    await addEmployeeUseCase(event.employee);
    emit(const EmployeeOperationSuccess('Employee added successfully'));
    
    // Reload employees
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

### 3. Widget reacts to state changes

```dart
// employee_add_screen.dart
BlocConsumer<EmployeeBloc, EmployeeState>(
  listener: (context, state) {
    if (state is EmployeeOperationSuccess) {
      Navigator.pop(context);  // Close form
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
    
    if (state is EmployeeError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${state.message}')),
      );
    }
  },
  builder: (context, state) {
    final isLoading = state is EmployeeOperationLoading;
    
    return Scaffold(
      body: isLoading
          ? CircularProgressIndicator()
          : Form(...),  // Show form
    );
  },
)
```

## State Flow Diagram

```
Initial State
     │
     ▼
Loading State ──> Loaded State ──> Search State
     │                                  │
     └──> Error State                   └──> Error State
```

## Best Practices

1. **Keep events simple**: One event = one action
2. **Immutable states**: Never modify state directly, create new state
3. **Clear state names**: Use descriptive names (EmployeeLoaded, not Loaded)
4. **Handle all states**: Always handle Loading, Loaded, and Error states
5. **Use copyWith**: For updating complex states

Example of copyWith:

```dart
class EmployeeLoaded extends EmployeeState {
  final List<Employee> employees;
  final List<Employee> filteredEmployees;
  final String? errorMessage;

  EmployeeLoaded copyWith({
    List<Employee>? employees,
    List<Employee>? filteredEmployees,
    String? errorMessage,
  }) {
    return EmployeeLoaded(
      employees: employees ?? this.employees,
      filteredEmployees: filteredEmployees ?? this.filteredEmployees,
      errorMessage: errorMessage,
    );
  }
}

// Usage
emit(state.copyWith(errorMessage: 'Offline mode'));
```

## Testing BLoC

```dart
test('should emit loaded state when employees are loaded', () async {
  // Arrange
  when(mockRepository.getEmployees()).thenAnswer((_) async => employees);
  
  // Act
  bloc.add(const LoadEmployees());
  
  // Assert
  expect(
    bloc.stream,
    emitsInOrder([
      EmployeeLoading(),
      EmployeeLoaded(employees: employees),
    ]),
  );
});
```

## Next Steps

- [Dependency Injection](./05_DEPENDENCY_INJECTION.md) - How BLoC is provided
- [Code Examples](./06_CODE_EXAMPLES.md) - More practical examples

