// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class EmployeeRealm extends $EmployeeRealm
    with RealmEntity, RealmObjectBase, RealmObject {
  EmployeeRealm(
    String id,
    String name,
    String email,
    String position,
    String department,
    DateTime joinDate,
    String phone,
    double salary,
  ) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'email', email);
    RealmObjectBase.set(this, 'position', position);
    RealmObjectBase.set(this, 'department', department);
    RealmObjectBase.set(this, 'joinDate', joinDate);
    RealmObjectBase.set(this, 'phone', phone);
    RealmObjectBase.set(this, 'salary', salary);
  }

  EmployeeRealm._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String get email => RealmObjectBase.get<String>(this, 'email') as String;
  @override
  set email(String value) => RealmObjectBase.set(this, 'email', value);

  @override
  String get position =>
      RealmObjectBase.get<String>(this, 'position') as String;
  @override
  set position(String value) => RealmObjectBase.set(this, 'position', value);

  @override
  String get department =>
      RealmObjectBase.get<String>(this, 'department') as String;
  @override
  set department(String value) =>
      RealmObjectBase.set(this, 'department', value);

  @override
  DateTime get joinDate =>
      RealmObjectBase.get<DateTime>(this, 'joinDate') as DateTime;
  @override
  set joinDate(DateTime value) => RealmObjectBase.set(this, 'joinDate', value);

  @override
  String get phone => RealmObjectBase.get<String>(this, 'phone') as String;
  @override
  set phone(String value) => RealmObjectBase.set(this, 'phone', value);

  @override
  double get salary => RealmObjectBase.get<double>(this, 'salary') as double;
  @override
  set salary(double value) => RealmObjectBase.set(this, 'salary', value);

  @override
  Stream<RealmObjectChanges<EmployeeRealm>> get changes =>
      RealmObjectBase.getChanges<EmployeeRealm>(this);

  @override
  Stream<RealmObjectChanges<EmployeeRealm>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<EmployeeRealm>(this, keyPaths);

  @override
  EmployeeRealm freeze() => RealmObjectBase.freezeObject<EmployeeRealm>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'name': name.toEJson(),
      'email': email.toEJson(),
      'position': position.toEJson(),
      'department': department.toEJson(),
      'joinDate': joinDate.toEJson(),
      'phone': phone.toEJson(),
      'salary': salary.toEJson(),
    };
  }

  static EJsonValue _toEJson(EmployeeRealm value) => value.toEJson();
  static EmployeeRealm _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'name': EJsonValue name,
        'email': EJsonValue email,
        'position': EJsonValue position,
        'department': EJsonValue department,
        'joinDate': EJsonValue joinDate,
        'phone': EJsonValue phone,
        'salary': EJsonValue salary,
      } =>
        EmployeeRealm(
          fromEJson(id),
          fromEJson(name),
          fromEJson(email),
          fromEJson(position),
          fromEJson(department),
          fromEJson(joinDate),
          fromEJson(phone),
          fromEJson(salary),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(EmployeeRealm._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, EmployeeRealm, 'EmployeeRealm', [
      SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('email', RealmPropertyType.string),
      SchemaProperty('position', RealmPropertyType.string),
      SchemaProperty('department', RealmPropertyType.string),
      SchemaProperty('joinDate', RealmPropertyType.timestamp),
      SchemaProperty('phone', RealmPropertyType.string),
      SchemaProperty('salary', RealmPropertyType.double),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
