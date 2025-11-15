import 'package:realm/realm.dart';

class RealmDataSource<T extends RealmObject>{

  Realm realm;
  RealmDataSource(this.realm);

  List<T> getAll(){
    return realm.all<T>().toList();
  }

  T? findById(dynamic id){
    return realm.find<T>(id);
  }

  void insert(T obj){
    realm.write(() {
      realm.add(obj,update: true);
    },);
  }

  void delete(T obj){
    realm.write(() {
      realm.delete(obj);
    },);
  }

}