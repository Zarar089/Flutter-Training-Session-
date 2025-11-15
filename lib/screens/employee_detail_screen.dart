import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:realm/realm.dart';
import 'package:intl/intl.dart';
import '../data/models/reals_models/employee/employee_model.dart';
import 'employee_add_screen.dart';

// ⚠️ SPAGHETTI CODE - ALL LOGIC IN ONE FILE
class EmployeeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> employee;

  const EmployeeDetailScreen({Key? key, required this.employee}) : super(key: key);

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  final DatabaseReference _firebaseRef = FirebaseDatabase.instance.ref('employees');
  late Realm _realm;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initRealm();
  }

  void _initRealm() {
    final config = Configuration.local([EmployeeRealm.schema]);
    _realm = Realm(config);
  }

  // Delete employee
  Future<void> _deleteEmployee() async {
    setState(() => isLoading = true);

    try {
      await _firebaseRef.child(widget.employee['id']).remove();

      _realm.write(() {
        final emp = _realm.find<EmployeeRealm>(widget.employee['id']);
        if (emp != null) {
          _realm.delete(emp);
        }
      });

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee deleted successfully')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // Navigate to edit screen
  void _navigateToEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeAddScreen(employee: widget.employee),
      ),
    ).then((updated) {
      if (updated == true) {
        Navigator.pop(context, true);
      }
    });
  }

  // Calculate years of service
  int _calculateYearsOfService() {
    final joinDate = widget.employee['joinDate'] as DateTime;
    final now = DateTime.now();
    return now.year - joinDate.year;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _showDeleteDialog,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      child: Text(
                        widget.employee['name'].toString()[0].toUpperCase(),
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.employee['name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.employee['position'],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Contact Information
            const Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoCard(Icons.email, 'Email', widget.employee['email']),
            _buildInfoCard(Icons.phone, 'Phone', widget.employee['phone']),

            const SizedBox(height: 24),

            // Work Information
            const Text(
              'Work Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoCard(Icons.business, 'Department', widget.employee['department']),
            _buildInfoCard(Icons.work, 'Position', widget.employee['position']),
            _buildInfoCard(
              Icons.calendar_today,
              'Join Date',
              dateFormat.format(widget.employee['joinDate']),
            ),
            _buildInfoCard(
              Icons.timeline,
              'Years of Service',
              '${_calculateYearsOfService()} years',
            ),
            _buildInfoCard(
              Icons.attach_money,
              'Salary',
              currencyFormat.format(widget.employee['salary']),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(label, style: const TextStyle(fontSize: 12)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to delete ${widget.employee['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEmployee();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _realm.close();
    super.dispose();
  }
}