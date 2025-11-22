# Employee Management App - Clean Architecture Documentation

This documentation explains the Clean Architecture implementation for the Employee Management App.

## 📚 Documentation Index

1. [Architecture Overview](./01_ARCHITECTURE_OVERVIEW.md) - Introduction to Clean Architecture
2. [Project Structure](./02_PROJECT_STRUCTURE.md) - Folder organization and layer structure
3. [Data Flow](./03_DATA_FLOW.md) - How data moves through the application
4. [BLoC Pattern](./04_BLOC_PATTERN.md) - State management implementation
5. [Dependency Injection](./05_DEPENDENCY_INJECTION.md) - GetIt setup and usage
6. [Code Examples](./06_CODE_EXAMPLES.md) - Practical examples of common operations
7. [Migration Guide](./07_MIGRATION_GUIDE.md) - What changed from spaghetti code

## 🎯 Quick Start

1. **Understanding the Layers**: Read [Architecture Overview](./01_ARCHITECTURE_OVERVIEW.md)
2. **Exploring Structure**: Check [Project Structure](./02_PROJECT_STRUCTURE.md)
3. **Understanding Flow**: Review [Data Flow](./03_DATA_FLOW.md)
4. **Learning BLoC**: Study [BLoC Pattern](./04_BLOC_PATTERN.md)

## 🏗️ Architecture Layers

```
┌─────────────────────────────────────┐
│      Presentation Layer (UI)        │
│         - Widgets                   │
│         - BLoC (State Management)   │
└─────────────────┬───────────────────┘
                  │
┌─────────────────▼───────────────────┐
│        Domain Layer (Business)      │
│         - Entities                  │
│         - Use Cases                 │
│         - Repository Interfaces     │
└─────────────────┬───────────────────┘
                  │
┌─────────────────▼───────────────────┐
│        Data Layer (Implementation)  │
│         - Repository Impl           │
│         - Data Sources              │
│         - Models                    │
└─────────────────────────────────────┘
```

## 📖 Key Concepts

- **Separation of Concerns**: Each layer has a specific responsibility
- **Dependency Inversion**: Domain layer doesn't depend on Data layer
- **Single Responsibility**: Each class does one thing well
- **Testability**: Easy to test each layer independently

## 🔄 Data Flow Example

**Adding an Employee:**

1. User taps "Add" button → **Widget** (Presentation)
2. Widget dispatches `AddEmployee` event → **BLoC** (Presentation)
3. BLoC calls `AddEmployeeUseCase` → **Use Case** (Domain)
4. Use Case calls `EmployeeRepository.addEmployee()` → **Repository Interface** (Domain)
5. `EmployeeRepositoryImpl` implements the call → **Repository Implementation** (Data)
6. Repository saves to Firebase & Realm → **Data Sources** (Data)
7. Success state flows back through layers → **Widget** (Presentation)

For detailed explanation, see [Data Flow](./03_DATA_FLOW.md).

