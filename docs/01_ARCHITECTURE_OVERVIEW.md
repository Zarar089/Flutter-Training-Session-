# Architecture Overview

## What is Clean Architecture?

Clean Architecture is a software design philosophy that separates concerns into different layers, making the codebase more maintainable, testable, and scalable.

## Why Clean Architecture?

### Problems with Spaghetti Code (Before)

❌ **Everything mixed together:**
- UI widgets contained business logic
- Direct database access in UI
- No separation of concerns
- Hard to test
- Difficult to maintain
- Tight coupling

### Benefits of Clean Architecture (After)

✅ **Clear separation:**
- UI only handles presentation
- Business logic isolated
- Easy to test each layer
- Easy to maintain
- Loose coupling
- Scalable structure

## Three Main Layers

### 1. Presentation Layer (UI)
**Location:** `lib/presentation/` and `lib/screens/`

**Responsibility:**
- User interface (Widgets)
- State management (BLoC)
- User interactions

**Should NOT:**
- Access databases directly
- Contain business logic
- Know about data sources

### 2. Domain Layer (Business Logic)
**Location:** `lib/domain/`

**Responsibility:**
- Business rules
- Use cases (what the app can do)
- Entity definitions
- Repository interfaces (contracts)

**Should NOT:**
- Know about UI
- Know about data sources (Firebase, Realm, etc.)
- Have external dependencies (Flutter SDK only)

### 3. Data Layer (Implementation)
**Location:** `lib/data/`

**Responsibility:**
- Repository implementations
- Data sources (Firebase, Realm, SharedPreferences)
- Data models
- API calls
- Local caching

**Should:**
- Implement domain repository interfaces
- Handle data conversion (maps, models, entities)

## Dependency Rule

```
Presentation → Domain ← Data
```

**Key Principle:** Dependencies always point inward!

- **Presentation** depends on **Domain**
- **Data** depends on **Domain**
- **Domain** depends on **nothing** (except Flutter SDK)

This means:
- Domain layer doesn't know about Firebase, Realm, or UI
- Business logic is independent and can be tested easily
- We can change data sources without affecting business logic

## Example: Adding an Employee

### Old Way (Spaghetti Code)
```dart
// In Widget - EVERYTHING mixed together
void _saveEmployee() {
  final firebaseRef = FirebaseDatabase.instance.ref('employees');
  final realm = Realm(config);
  
  // Business logic in UI widget!
  final employeeId = DateTime.now().millisecondsSinceEpoch.toString();
  final employeeData = {...};
  
  await firebaseRef.child(employeeId).set(employeeData);
  realm.write(() {
    realm.add(EmployeeRealm(...));
  });
}
```

### New Way (Clean Architecture)
```dart
// Widget - Only UI concerns
void _saveEmployee() {
  context.read<EmployeeBloc>().add(
    AddEmployee(employee)
  );
}

// BLoC - State management
Future<void> _onAddEmployee(...) async {
  await addEmployeeUseCase(employee);
  emit(EmployeeOperationSuccess());
}

// Use Case - Business logic
Future<void> call(Employee employee) async {
  return await repository.addEmployee(employee);
}

// Repository - Data implementation
Future<void> addEmployee(Employee employee) async {
  await firebaseRef.set(...);
  realmDataSource.insert(...);
}
```

## Benefits in This Project

1. **Testability**: Each layer can be tested independently
2. **Maintainability**: Changes in one layer don't affect others
3. **Scalability**: Easy to add new features
4. **Readability**: Clear structure and responsibilities
5. **Flexibility**: Can change data sources without rewriting business logic

## Next Steps

- [Project Structure](./02_PROJECT_STRUCTURE.md) - See how files are organized
- [Data Flow](./03_DATA_FLOW.md) - Understand how data moves through layers

