import 'package:shared_preferences/shared_preferences.dart';
class SharedPreferencesLocal<T> {
  Future<void> _checkLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getString('last_sync_employees');
    if (lastSync != null) {
      debugPrint('Last synced: $lastSync');
    }
  }

  Future<void> _loadEmployees() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Try Firebase first
      final snapshot = await _firebaseRef.get();

      if (snapshot.exists) {
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
      employees = realmData
          .map((emp) => {
                'id': emp.id,
                'name': emp.name,
                'email': emp.email,
                'position': emp.position,
                'department': emp.department,
                'joinDate': emp.joinDate,
                'phone': emp.phone,
                'salary': emp.salary,
              })
          .toList();

      errorMessage = 'Loaded from cache (offline)';
    }

    filteredEmployees = employees;
    setState(() => isLoading = false);
  }
}
