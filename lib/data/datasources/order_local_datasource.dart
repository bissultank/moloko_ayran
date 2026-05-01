// Слой: data | Назначение: локальный datasource для заказов (Drift)

import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/entities/order.dart';
import 'app_database.dart';

class OrderLocalDatasource {
  OrderLocalDatasource(this._db);

  final AppDatabase _db;

  Future<List<OrderEntity>> getByUserId(int userId) async {
    final rows = await (_db.select(_db.orders)
          ..where((o) => o.userId.equals(userId))
          ..orderBy([(o) => OrderingTerm.desc(o.createdAt)]))
        .get();
    return rows.map(_toEntity).toList();
  }

  Future<List<OrderEntity>> getByUserIdAndStatus(
      int userId, OrderStatus status) async {
    final rows = await (_db.select(_db.orders)
          ..where((o) => o.userId.equals(userId) & o.status.equals(status.name))
          ..orderBy([(o) => OrderingTerm.desc(o.createdAt)]))
        .get();
    return rows.map(_toEntity).toList();
  }

  Future<int> create(OrderEntity order) async {
    final itemsJson = jsonEncode(order.items.map((e) => e.toJson()).toList());
    return _db.into(_db.orders).insert(
          OrdersCompanion.insert(
            userId: order.userId,
            itemsJson: itemsJson,
            totalPrice: order.totalPrice,
            status: order.status.name,
            createdAt: order.createdAt,
            addressLabel: Value(order.addressLabel),
            addressFull: Value(order.addressFull),
          ),
        );
  }

  Future<void> updateStatus(int orderId, OrderStatus status) async {
    await (_db.update(_db.orders)..where((o) => o.id.equals(orderId)))
        .write(OrdersCompanion(status: Value(status.name)));
  }

  Future<void> delete(int orderId) async {
    await (_db.delete(_db.orders)..where((o) => o.id.equals(orderId))).go();
  }

  OrderEntity _toEntity(OrderRow row) {
    final List<dynamic> rawItems = jsonDecode(row.itemsJson);
    final items = rawItems
        .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return OrderEntity(
      id: row.id,
      userId: row.userId,
      items: items,
      totalPrice: row.totalPrice,
      status: OrderStatus.fromString(row.status),
      createdAt: row.createdAt,
      addressLabel: row.addressLabel,
      addressFull: row.addressFull,
    );
  }
}
