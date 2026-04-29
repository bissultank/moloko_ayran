// Слой: data | Назначение: Drift-таблица Addresses

import 'package:drift/drift.dart';

@DataClassName('AddressRow')
class Addresses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer()();
  TextColumn get label => text()();
  TextColumn get street => text()();
  TextColumn get apartment => text().withDefault(const Constant(''))();
  TextColumn get city => text()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
}
