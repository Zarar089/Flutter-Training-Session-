# Project Structure

## Folder Organization

```
lib/
├── core/                          # Core functionality
│   └── di/                        # Dependency Injection
│       └── injection_container.dart
│
├── data/                          # Data Layer
│   ├── data_source/               # Data sources (Firebase, Realm, etc.)
│   │   ├── local_data_source/
│   │   │   ├── realm_db.dart
│   │   │   └── shared_preference_data_source.dart
│   │   └── remote_data_source/
│   │       └── firebase_data_source.dart
│   ├── mappers/                   # Entity ↔ Model converters
│   │   ├── employee_mapper.dart
│   │   └── attendance_mapper.dart
│   ├── models/                    # Data models (Realm, etc.)
│   │   └── realm_mdoels/
│   │       └── employee_model.dart
│   └── repositories/              # Repository implementations
│       ├── employee_repository_impl.dart
│       ├── attendance_repository_impl.dart
│       └── sync_repository_impl.dart
│
├── domain/                        # Domain Layer (Business Logic)
│   ├── entities/                  # Business objects
│   │   ├── employee.dart
│   │   └── attendance.dart
│   ├── repositories/              # Repository interfaces (contracts)
│   │   ├── employee_repository.dart
│   │   ├── attendance_repository.dart
│   │   └── sync_repository.dart
│   └── usecases/                  # Business use cases
│       ├── employee/
│       │   ├── get_employees_usecase.dart
│       │   ├── add_employee_usecase.dart
│       │   ├── update_employee_usecase.dart
│       │   ├── delete_employee_usecase.dart
│       │   ├── search_employees_usecase.dart
│       │   └── get_employee_by_id_usecase.dart
│       ├── attendance/
│       │   ├── get_attendance_records_usecase.dart
│       │   ├── check_in_usecase.dart
│       │   ├── check_out_usecase.dart
│       │   └── calculate_monthly_hours_usecase.dart
│       └── sync/
│           ├── get_last_sync_usecase.dart
│           └── set_last_sync_usecase.dart
│
├── presentation/                  # Presentation Layer (UI)
│   └── bloc/                      # BLoC (State Management)
│       ├── employee/
│       │   ├── employee_bloc.dart
│       │   ├── employee_event.dart
│       │   └── employee_state.dart
│       └── attendance/
│           ├── attendance_bloc.dart
│           ├── attendance_event.dart
│           └── attendance_state.dart
│
└── screens/                       # UI Screens (Widgets)
    ├── employee_list_screen.dart
    ├── employee_add_screen.dart
    ├── employee_detail_screen.dart
    └── attendance_screen.dart
```

## Layer Details

### 📱 Presentation Layer (`lib/presentation/` & `lib/screens/`)

**Purpose:** Handle user interface and state management

**Components:**

1. **Screens** (`lib/screens/`)
   - Pure UI widgets
   - Display data from BLoC
   - Dispatch events to BLoC
   - NO business logic

2. **BLoC** (`lib/presentation/bloc/`)
   - State management
   - Handles events from UI
   - Calls use cases
   - Emits states to UI

**Example Structure:**
```
employee/
├── employee_bloc.dart      # Main BLoC logic
├── employee_event.dart     # Events (LoadEmployees, AddEmployee, etc.)
└── employee_state.dart     # States (Loading, Loaded, Error, etc.)
```

### 🧠 Domain Layer (`lib/domain/`)

**Purpose:** Contains business logic and rules

**Components:**

1. **Entities** (`domain/entities/`)
   - Pure Dart classes
   - Business objects
   - No framework dependencies
   - Example: `Employee`, `Attendance`

2. **Use Cases** (`domain/usecases/`)
   - Single responsibility per use case
   - Business operations
   - Example: `GetEmployeesUseCase`, `AddEmployeeUseCase`

3. **Repository Interfaces** (`domain/repositories/`)
   - Contracts/Interfaces
   - Define what data operations are needed
   - Implemented by Data layer

**Key Rule:** Domain layer has NO dependencies on external frameworks (except Dart/Flutter core)

### 💾 Data Layer (`lib/data/`)

**Purpose:** Handle data operations and external services

**Components:**

1. **Data Sources** (`data/data_source/`)
   - Firebase operations
   - Realm database operations
   - SharedPreferences operations

2. **Models** (`data/models/`)
   - Data representation models
   - Realm models, API models
   - Can have framework-specific annotations

3. **Mappers** (`data/mappers/`)
   - Convert between Entities and Models
   - Example: `EmployeeMapper.fromRealm()`

4. **Repository Implementations** (`data/repositories/`)
   - Implement domain repository interfaces
   - Coordinate data sources
   - Handle caching logic

### 🔧 Core (`lib/core/`)

**Purpose:** Shared infrastructure

**Components:**

1. **Dependency Injection** (`core/di/`)
   - GetIt setup
   - Register all dependencies
   - Wire everything together

## File Naming Conventions

- **Entities**: `employee.dart`, `attendance.dart`
- **Use Cases**: `get_employees_usecase.dart`, `add_employee_usecase.dart`
- **Repositories**: `employee_repository.dart` (interface), `employee_repository_impl.dart` (implementation)
- **BLoC**: `employee_bloc.dart`, `employee_event.dart`, `employee_state.dart`
- **Screens**: `employee_list_screen.dart`

## Dependency Flow

```
screens/
  └─> presentation/bloc/
        └─> domain/usecases/
              └─> domain/repositories/ (interfaces)
                    ←── data/repositories/ (implementations)
                          └─> data/data_source/
```

## Adding a New Feature

To add a new feature (e.g., "Departments"):

1. **Domain Layer**:
   - Create `domain/entities/department.dart`
   - Create `domain/repositories/department_repository.dart`
   - Create use cases in `domain/usecases/department/`

2. **Data Layer**:
   - Create `data/models/department_model.dart` (if needed)
   - Create `data/repositories/department_repository_impl.dart`
   - Add data sources if needed

3. **Presentation Layer**:
   - Create `presentation/bloc/department/department_bloc.dart`
   - Create events and states
   - Create `screens/department_list_screen.dart`

4. **DI**:
   - Register dependencies in `core/di/injection_container.dart`

## Next Steps

- [Data Flow](./03_DATA_FLOW.md) - See how data moves through these layers
- [BLoC Pattern](./04_BLOC_PATTERN.md) - Understand state management

