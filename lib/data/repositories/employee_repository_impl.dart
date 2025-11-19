import '../../domain/entities/employee.dart';
import '../../domain/repositories/employee_repository.dart';
import '../data_source/remote/firebase_employee_datasource.dart';
import '../data_source/local/realm_employee_datasource.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final FirebaseEmployeeDataSource remote;
  final RealmEmployeeDataSource local;

  EmployeeRepositoryImpl(this.remote, this.local);

  @override
  Future<List<Employee>> getEmployees() async {
    try {
      final employees = await remote.getEmployees();
      local.cacheEmployees(employees);  // offline cache
      return employees;
    } catch (e) {
      return local.getCachedEmployees(); // offline fallback
    }
  }

  @override
  Future<void> deleteEmployee(String id) async {
    await remote.deleteEmployee(id);
    local.deleteEmployee(id);
  }

  @override
  Future<void> addEmployee(Employee employee) async {
    await remote.addEmployee(employee);
    local.cacheEmployees(await remote.getEmployees());
  }

  @override
  Future<void> updateEmployee(Employee employee) async {
    await remote.addEmployee(employee); // Firebase .set() = upsert
    local.cacheEmployees(await remote.getEmployees());
  }
}
