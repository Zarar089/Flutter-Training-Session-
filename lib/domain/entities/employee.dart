class Employee {
  final String id;
  final String name;
  final String email;
  final String position;
  final String department;
  final String joinDate;
  final String phone;
  final int salary;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.position,
    required this.department,
    required this.joinDate,
    required this.phone,
    required this.salary,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'position': position,
    'department': department,
    'joinDate': joinDate,
    'phone': phone,
    'salary': salary,
  };
}