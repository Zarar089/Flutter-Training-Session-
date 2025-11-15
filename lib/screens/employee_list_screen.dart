import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:realm/realm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../employee_model.dart';
import 'employee_detail_screen.dart';
import 'employee_add_screen.dart';
import 'attendance_screen.dart';

// ⚠️ SPAGHETTI CODE - ALL LOGIC IN ONE FILE
// UI + Business Logic + Data Access all mixed together

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  // Direct Firebase reference - no abstraction
  final DatabaseReference _firebaseRef = FirebaseDatabase.instance.ref('employees');

  // Direct Realm instance - no abstraction
  late Realm _realm;

  // State management with setState
  List<Map<String, dynamic>> employees = [];
  List<Map<String, dynamic>> filteredEmployees = [];
  bool isLoading = false;
  String? errorMessage;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initRealm();
    _checkLastSync();
    _loadEmployees();
  }

  // Initialize Realm - direct dependency
  void _initRealm() {
    final config = Configuration.local([EmployeeRealm.schema]);
    _realm = Realm(config);
  }

  // Check last sync from SharedPreferences - direct dependency
  Future<void> _checkLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getString('last_sync_employees');
    if (lastSync != null) {
      debugPrint('Last synced: $lastSync');
    }
  }

  // Load employees - tries Firebase first, falls back to Realm
  Future<void> _loadEmployees() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Try Firebase first
      final snapshot = await _firebaseRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        employees = data.entries.map((entry) {
          final value = entry.value as Map<dynamic, dynamic>;
          return {
            'id': entry.key as String,
            'name': value['name'] as String,
            'email': value['email'] as String,
            'position': value['position'] as String,
            'department': value['department'] as String,
            'joinDate': DateTime.parse(value['joinDate'] as String),
            'phone': value['phone'] as String,
            'salary': (value['salary'] as num).toDouble(),
          };
        }).toList();

        // Cache to Realm
        _realm.write(() {
          _realm.deleteAll<EmployeeRealm>();
          for (var emp in employees) {
            _realm.add(EmployeeRealm(
              emp['id'],
              emp['name'],
              emp['email'],
              emp['position'],
              emp['department'],
              emp['joinDate'],
              emp['phone'],
              emp['salary'],
            ));
          }
        });

        // Save sync time to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'last_sync_employees',
          DateTime.now().toIso8601String(),
        );
      }
    } catch (e) {
      // Fallback to Realm if Firebase fails
      debugPrint('Firebase error: $e, loading from cache');
      final realmData = _realm.all<EmployeeRealm>();
      employees = realmData.map((emp) => {
        'id': emp.id,
        'name': emp.name,
        'email': emp.email,
        'position': emp.position,
        'department': emp.department,
        'joinDate': emp.joinDate,
        'phone': emp.phone,
        'salary': emp.salary,
      }).toList();

      errorMessage = 'Loaded from cache (offline)';
    }

    filteredEmployees = employees;
    setState(() => isLoading = false);
  }

  // Search functionality - business logic in UI
  void _searchEmployees(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredEmployees = employees;
      } else {
        filteredEmployees = employees.where((emp) {
          return emp['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
              emp['position'].toString().toLowerCase().contains(query.toLowerCase()) ||
              emp['department'].toString().toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  // Delete employee - direct Firebase and Realm access
  Future<void> _deleteEmployee(String id) async {
    try {
      await _firebaseRef.child(id).remove();

      _realm.write(() {
        final emp = _realm.find<EmployeeRealm>(id);
        if (emp != null) {
          _realm.delete(emp);
        }
      });

      _loadEmployees();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting employee: $e')),
        );
      }
    }
  }

  // Navigate to detail screen
  void _navigateToDetail(Map<String, dynamic> employee) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeDetailScreen(employee: employee),
      ),
    ).then((_) => _loadEmployees());
  }

  // Navigate to add screen
  void _navigateToAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EmployeeAddScreen(),
      ),
    ).then((_) => _loadEmployees());
  }

  // Navigate to attendance screen
  void _navigateToAttendance() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AttendanceScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        actions: [
          IconButton(
            icon: const Icon(Icons.access_time),
            onPressed: _navigateToAttendance,
            tooltip: 'Attendance',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEmployees,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search employees...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _searchEmployees,
            ),
          ),

          // Error message banner
          if (errorMessage != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.orange.shade100,
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(errorMessage!),
                ],
              ),
            ),

          // Employee list
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredEmployees.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    searchQuery.isEmpty ? 'No employees found' : 'No matching employees',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: filteredEmployees.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final employee = filteredEmployees[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        employee['name'].toString()[0].toUpperCase(),
                      ),
                    ),
                    title: Text(
                      employee['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${employee['position']} - ${employee['department']}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteDialog(employee['id']),
                    ),
                    onTap: () => _navigateToDetail(employee),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAdd,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: const Text('Are you sure you want to delete this employee?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEmployee(id);
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