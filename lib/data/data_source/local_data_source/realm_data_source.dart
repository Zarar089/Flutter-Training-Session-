import 'package:realm/realm.dart';

class RealmDatSource<T extends RealmObject>
{
  Realm _realm;
  RealmDatSource(this._realm);

  List<T> getAll()
  {
    return _realm.all<T>().toList();
  }

  T? findById(dynamic id)
  {
    return _realm.find(id);
  }

  void insert(T obj)
  {
    _realm.write((){
      _realm.add(obj);
    });
  }

  void delete(T obj)
  {
    _realm.write((){
      _realm.delete(obj);
    });
  }
}