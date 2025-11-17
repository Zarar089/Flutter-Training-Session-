import 'package:employee_app_v1_spaghetti/domain/entities/base_entity.dart';

class Employee extends BaseEntity{
  late String id;
  late String name;
  late String email;
  late String position;
  late String department;
  late DateTime joinDate;
  late String phone;
  late double salary;

  Employee.empty();

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.position,
    required this.department,
    required this.joinDate,
    required this.phone,
    required this.salary,
  }) : super();

  @override
  BaseEntity fromMap(Map<dynamic,dynamic> data) {
    id = data['id'] as String;
    name = data['name'] as String;
    email = data['email'] as String;
    position = data['position'] as String;
    department = data['department'] as String;
    joinDate = DateTime.parse(data['joinDate'] as String);
    phone = data['phone'] as String;
    salary = (data['salary'] as num).toDouble();
    return this;
  }
}