import '../../domain/entities/employee_entity.dart';

class EmployeeModel extends EmployeeEntity {
  const EmployeeModel({
    required String id,
    required String name,
    required String email,
    required String position,
    required String department,
    required DateTime joinDate,
    required String phone,
    required double salary,
  }) : super(
          id: id,
          name: name,
          email: email,
          position: position,
          department: department,
          joinDate: joinDate,
          phone: phone,
          salary: salary,
        );

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      position: json['position'] as String,
      department: json['department'] as String,
      joinDate: DateTime.parse(json['joinDate'] as String),
      phone: json['phone'] as String,
      salary: (json['salary'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'position': position,
      'department': department,
      'joinDate': joinDate.toIso8601String(),
      'phone': phone,
      'salary': salary,
    };
  }

  factory EmployeeModel.fromEntity(EmployeeEntity entity) {
    return EmployeeModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      position: entity.position,
      department: entity.department,
      joinDate: entity.joinDate,
      phone: entity.phone,
      salary: entity.salary,
    );
  }
}