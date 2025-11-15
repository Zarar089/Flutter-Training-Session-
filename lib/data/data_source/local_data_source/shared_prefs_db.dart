import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/entities/employee.dart'; 

class SharedPrefsDb {

  static const String keyLastEmployeeSync = 'last_sync_employees';

  static Future<void> saveLastEmployeeSync() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      keyLastEmployeeSync,
      DateTime.now().toIso8601String(),
    );
  }

  static Future<String?> getLastEmployeeSync() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyLastEmployeeSync);
  }

  static Future<void> clearLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyLastEmployeeSync);
  }

  static const String keyEmployeeDraft = 'employee_draft';

  /// Save draft as JSON
  static Future<void> saveEmployeeDraft(Employee employee) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(employee.toMap());
    await prefs.setString(keyEmployeeDraft, jsonString);
  }

  /// Load draft into Employee model
  static Future<Employee?> loadEmployeeDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(keyEmployeeDraft);

    if (jsonString == null) return null;

    final Map<String, dynamic> data = jsonDecode(jsonString);

    return Employee(
      id: "draft",
      name: data['name'],
      email: data['email'],
      position: data['position'],
      department: data['department'],
      joinDate: DateTime.parse(data['joinDate']),
      phone: data['phone'],
      salary: (data['salary'] as num).toDouble(),
    );
  }

  static Future<void> clearEmployeeDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyEmployeeDraft);
  }
}
