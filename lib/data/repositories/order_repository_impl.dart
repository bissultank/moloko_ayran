// Слой: data | Назначение: реализация OrderRepository

import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_local_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl(this._datasource);

  final OrderLocalDatasource _datasource;

  @override
  Future<List<OrderEntity>> getByUserId(int userId) =>
      _datasource.getByUserId(userId);

  @override
  Future<List<OrderEntity>> getByUserIdAndStatus(
          int userId, OrderStatus status) =>
      _datasource.getByUserIdAndStatus(userId, status);

  @override
  Future<int> create(OrderEntity order) => _datasource.create(order);

  @override
  Future<void> updateStatus(int orderId, OrderStatus status) =>
      _datasource.updateStatus(orderId, status);

  @override
  Future<void> delete(int orderId) => _datasource.delete(orderId);
}
