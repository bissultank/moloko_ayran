// Слой: data | Назначение: определение Drift-таблицы Users

import 'package:drift/drift.dart';

// Drift генерирует класс UserRow (не User) — чтобы не конфликтовать с domain/entities/user.dart
@DataClassName('UserRow')
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get email => text().unique()();
  TextColumn get password => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
}
