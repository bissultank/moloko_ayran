part of 'order_bloc.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();
  @override
  List<Object?> get props => [];
}

class OrderLoadAll extends OrderEvent {
  const OrderLoadAll(this.userId);
  final int userId;
  @override
  List<Object?> get props => [userId];
}

class OrderFilterByStatus extends OrderEvent {
  const OrderFilterByStatus(this.status);
  final OrderStatus? status;
  @override
  List<Object?> get props => [status];
}

class OrderCreate extends OrderEvent {
  const OrderCreate(this.order);
  final OrderEntity order;
  @override
  List<Object?> get props => [order];
}

class OrderUpdateStatus extends OrderEvent {
  const OrderUpdateStatus(this.orderId, this.status);
  final int orderId;
  final OrderStatus status;
  @override
  List<Object?> get props => [orderId, status];
}

class OrderDelete extends OrderEvent {
  const OrderDelete(this.orderId);
  final int orderId;
  @override
  List<Object?> get props => [orderId];
}
