// Слой: data | Назначение: Drift-таблица Products

import 'package:drift/drift.dart';

@DataClassName('ProductRow')
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get category => text()(); // enum как строка
  RealColumn get price => real()();
  TextColumn get unit => text()();
  TextColumn get farmer => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  BoolColumn get isAvailable => boolean().withDefault(const Constant(true))();
}
