import 'package:flutter/material.dart';
import '../../domain/entities/employee_entity.dart';

class EmployeeCard extends StatelessWidget {
  final EmployeeEntity employee;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const EmployeeCard({
    Key? key,
    required this.employee,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            employee.name[0].toUpperCase(),
          ),
        ),
        title: Text(
          employee.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${employee.position} - ${employee.department}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}