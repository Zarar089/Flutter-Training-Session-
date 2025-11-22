
import 'package:employee_app_v1_spaghetti/domain/entities/base_entity.dart';
import 'package:employee_app_v1_spaghetti/domain/entities/employee.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseDataSource<T extends BaseEntity>{
  final DatabaseReference _firebaseRef;
  FirebaseDataSource(this._firebaseRef);

  Future<List<BaseEntity>> getData() async{
    final snapshot = await _firebaseRef.get();
    List<BaseEntity> employees = [];
    if(snapshot.exists){
      final data = snapshot.value as Map<dynamic, dynamic>;
      employees = data.entries.map((entry) {
        Employee employee = Employee.empty();
        return employee.fromMap(Map<dynamic,dynamic>.from(entry.value));
      }).toList();
    }
    return employees;
  }
}