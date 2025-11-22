import '../../domain/entities/employee.dart';
import '../models/reals_models/employee/employee_model.dart';

class EmployeeMapper {
  static Employee fromRealm(EmployeeRealm realm) {
    return Employee(
      id: realm.id,
      name: realm.name,
      email: realm.email,
      position: realm.position,
      department: realm.department,
      joinDate: realm.joinDate,
      phone: realm.phone,
      salary: realm.salary,
    );
  }

  static EmployeeRealm toRealm(Employee employee) {
    return EmployeeRealm(
      employee.id,
      employee.name,
      employee.email,
      employee.position,
      employee.department,
      employee.joinDate,
      employee.phone,
      employee.salary,
    );
  }

  static Employee fromMap(String id, Map<dynamic, dynamic> data) {
    return Employee(
      id: id,
      name: data['name'] as String,
      email: data['email'] as String,
      position: data['position'] as String,
      department: data['department'] as String,
      joinDate: DateTime.parse(data['joinDate'] as String),
      phone: data['phone'] as String,
      salary: (data['salary'] as num).toDouble(),
    );
  }

  static Map<String, dynamic> toMap(Employee employee) {
    return {
      'name': employee.name,
      'email': employee.email,
      'position': employee.position,
      'department': employee.department,
      'joinDate': employee.joinDate.toIso8601String(),
      'phone': employee.phone,
      'salary': employee.salary,
    };
  }
}

