import '../../domain/entities/employee.dart';
import '../models/realm_mdoels/employee_model.dart';

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

  static Employee fromMap(String id, Map<String, dynamic> map) {
    return Employee(
      id: id,
      name: map['name'] as String,
      email: map['email'] as String,
      position: map['position'] as String,
      department: map['department'] as String,
      joinDate: map['joinDate'] is DateTime
          ? map['joinDate'] as DateTime
          : DateTime.parse(map['joinDate'] as String),
      phone: map['phone'] as String,
      salary: (map['salary'] as num).toDouble(),
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

