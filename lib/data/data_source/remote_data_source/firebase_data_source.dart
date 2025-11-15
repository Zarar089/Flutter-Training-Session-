
import 'package:employee_app_v1_spaghetti/domain/entities/employee.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseDataSource<T extends Object>{
  DatabaseReference _firebaseRef;
  FirebaseDataSource(this._firebaseRef);

  Future<List<Map<String,Object>>> getData() async{
    final snapshot = await _firebaseRef.get();
    List<Map<String,Object>> employees = [];
    if(snapshot.exists){
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
    }
    return employees;
  }
}