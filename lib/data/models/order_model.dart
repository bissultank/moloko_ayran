// Слой: data | Назначение: Drift-таблица Orders

import 'package:drift/drift.dart';

@DataClassName('OrderRow')
class Orders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer()();
  TextColumn get itemsJson => text()();
  RealColumn get totalPrice => real()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get addressLabel => text().withDefault(const Constant(''))();
  TextColumn get addressFull => text().withDefault(const Constant(''))();
}
