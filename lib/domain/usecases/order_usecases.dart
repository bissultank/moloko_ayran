// Слой: domain | Назначение: use cases для заказов

import '../entities/order.dart';
import '../repositories/order_repository.dart';

class GetUserOrdersUseCase {
  GetUserOrdersUseCase(this._repository);
  final OrderRepository _repository;
  Future<List<OrderEntity>> call(int userId) => _repository.getByUserId(userId);
}

class GetOrdersByStatusUseCase {
  GetOrdersByStatusUseCase(this._repository);
  final OrderRepository _repository;
  Future<List<OrderEntity>> call(int userId, OrderStatus status) =>
      _repository.getByUserIdAndStatus(userId, status);
}

class CreateOrderUseCase {
  CreateOrderUseCase(this._repository);
  final OrderRepository _repository;
  Future<int> call(OrderEntity order) => _repository.create(order);
}

class UpdateOrderStatusUseCase {
  UpdateOrderStatusUseCase(this._repository);
  final OrderRepository _repository;
  Future<void> call(int orderId, OrderStatus status) =>
      _repository.updateStatus(orderId, status);
}

class DeleteOrderUseCase {
  DeleteOrderUseCase(this._repository);
  final OrderRepository _repository;
  Future<void> call(int orderId) => _repository.delete(orderId);
}
