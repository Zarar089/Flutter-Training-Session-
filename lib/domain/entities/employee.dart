class Employee {
  late String id;
  late String name;
  late String email;
  late String position;
  late String department;
  late DateTime joinDate;
  late String phone;
  late double salary;

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

  factory Employee.fromMap(String id, Map<dynamic, dynamic> data) {
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

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'position': position,
      'department': department,
      'joinDate': joinDate.toIso8601String(),
      'phone': phone,
      'salary': salary,
    };
  }
}
