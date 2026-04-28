// Слой: domain | Назначение: интерфейс репозитория заказов

import '../entities/order.dart';

abstract class OrderRepository {
  Future<List<OrderEntity>> getByUserId(int userId);
  Future<List<OrderEntity>> getByUserIdAndStatus(
      int userId, OrderStatus status);
  Future<int> create(OrderEntity order);
  Future<void> updateStatus(int orderId, OrderStatus status);
  Future<void> delete(int orderId);
}
