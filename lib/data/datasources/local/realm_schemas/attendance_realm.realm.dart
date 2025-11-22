// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_realm.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class AttendanceRealm extends $AttendanceRealm
    with RealmEntity, RealmObjectBase, RealmObject {
  AttendanceRealm(
    String id,
    String employeeId,
    String employeeName,
    DateTime date,
    DateTime checkInTime,
    double totalHours,
    String status, {
    DateTime? checkOutTime,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'employeeId', employeeId);
    RealmObjectBase.set(this, 'employeeName', employeeName);
    RealmObjectBase.set(this, 'date', date);
    RealmObjectBase.set(this, 'checkInTime', checkInTime);
    RealmObjectBase.set(this, 'checkOutTime', checkOutTime);
    RealmObjectBase.set(this, 'totalHours', totalHours);
    RealmObjectBase.set(this, 'status', status);
  }

  AttendanceRealm._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get employeeId =>
      RealmObjectBase.get<String>(this, 'employeeId') as String;
  @override
  set employeeId(String value) =>
      RealmObjectBase.set(this, 'employeeId', value);

  @override
  String get employeeName =>
      RealmObjectBase.get<String>(this, 'employeeName') as String;
  @override
  set employeeName(String value) =>
      RealmObjectBase.set(this, 'employeeName', value);

  @override
  DateTime get date => RealmObjectBase.get<DateTime>(this, 'date') as DateTime;
  @override
  set date(DateTime value) => RealmObjectBase.set(this, 'date', value);

  @override
  DateTime get checkInTime =>
      RealmObjectBase.get<DateTime>(this, 'checkInTime') as DateTime;
  @override
  set checkInTime(DateTime value) =>
      RealmObjectBase.set(this, 'checkInTime', value);

  @override
  DateTime? get checkOutTime =>
      RealmObjectBase.get<DateTime>(this, 'checkOutTime') as DateTime?;
  @override
  set checkOutTime(DateTime? value) =>
      RealmObjectBase.set(this, 'checkOutTime', value);

  @override
  double get totalHours =>
      RealmObjectBase.get<double>(this, 'totalHours') as double;
  @override
  set totalHours(double value) =>
      RealmObjectBase.set(this, 'totalHours', value);

  @override
  String get status => RealmObjectBase.get<String>(this, 'status') as String;
  @override
  set status(String value) => RealmObjectBase.set(this, 'status', value);

  @override
  Stream<RealmObjectChanges<AttendanceRealm>> get changes =>
      RealmObjectBase.getChanges<AttendanceRealm>(this);

  @override
  Stream<RealmObjectChanges<AttendanceRealm>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<AttendanceRealm>(this, keyPaths);

  @override
  AttendanceRealm freeze() =>
      RealmObjectBase.freezeObject<AttendanceRealm>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'employeeId': employeeId.toEJson(),
      'employeeName': employeeName.toEJson(),
      'date': date.toEJson(),
      'checkInTime': checkInTime.toEJson(),
      'checkOutTime': checkOutTime.toEJson(),
      'totalHours': totalHours.toEJson(),
      'status': status.toEJson(),
    };
  }

  static EJsonValue _toEJson(AttendanceRealm value) => value.toEJson();
  static AttendanceRealm _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'employeeId': EJsonValue employeeId,
        'employeeName': EJsonValue employeeName,
        'date': EJsonValue date,
        'checkInTime': EJsonValue checkInTime,
        'totalHours': EJsonValue totalHours,
        'status': EJsonValue status,
      } =>
        AttendanceRealm(
          fromEJson(id),
          fromEJson(employeeId),
          fromEJson(employeeName),
          fromEJson(date),
          fromEJson(checkInTime),
          fromEJson(totalHours),
          fromEJson(status),
          checkOutTime: fromEJson(ejson['checkOutTime']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(AttendanceRealm._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, AttendanceRealm, 'AttendanceRealm', [
      SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('employeeId', RealmPropertyType.string),
      SchemaProperty('employeeName', RealmPropertyType.string),
      SchemaProperty('date', RealmPropertyType.timestamp),
      SchemaProperty('checkInTime', RealmPropertyType.timestamp),
      SchemaProperty('checkOutTime', RealmPropertyType.timestamp,
          optional: true),
      SchemaProperty('totalHours', RealmPropertyType.double),
      SchemaProperty('status', RealmPropertyType.string),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
