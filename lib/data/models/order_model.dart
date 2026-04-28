// Слой: data | Назначение: Drift-таблица Orders

import 'package:drift/drift.dart';

@DataClassName('OrderRow')
class Orders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer()();
  TextColumn get itemsJson => text()(); // JSON-строка со списком товаров
  RealColumn get totalPrice => real()();
  TextColumn get status => text()(); // enum как строка
  DateTimeColumn get createdAt => dateTime()();
}
