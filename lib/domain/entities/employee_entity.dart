import 'package:equatable/equatable.dart';

class EmployeeEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String position;
  final String department;
  final DateTime joinDate;
  final String phone;
  final double salary;

  const EmployeeEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.position,
    required this.department,
    required this.joinDate,
    required this.phone,
    required this.salary,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        position,
        department,
        joinDate,
        phone,
        salary,
      ];

  EmployeeEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? position,
    String? department,
    DateTime? joinDate,
    String? phone,
    double? salary,
  }) {
    return EmployeeEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      position: position ?? this.position,
      department: department ?? this.department,
      joinDate: joinDate ?? this.joinDate,
      phone: phone ?? this.phone,
      salary: salary ?? this.salary,
    );
  }
}