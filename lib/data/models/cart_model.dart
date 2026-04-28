// Слой: data | Назначение: Drift-таблица CartItems

import 'package:drift/drift.dart';

@DataClassName('CartItemRow')
class CartItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer()();
  IntColumn get productId => integer()();
  IntColumn get quantity => integer()();

  // Денормализованные данные продукта (чтобы корзина работала даже если продукт удалён)
  TextColumn get productName => text()();
  TextColumn get category => text()();
  RealColumn get price => real()();
  TextColumn get unit => text()();
  TextColumn get farmer => text()();
}
