part of 'order_bloc.dart';

abstract class OrderState extends Equatable {
  const OrderState();
  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {
  const OrderInitial();
}

class OrderLoading extends OrderState {
  const OrderLoading();
}

class OrderLoaded extends OrderState {
  const OrderLoaded(this.orders, {this.selectedStatus});
  final List<OrderEntity> orders;
  final OrderStatus? selectedStatus;
  @override
  List<Object?> get props => [orders, selectedStatus];
}

class OrderError extends OrderState {
  const OrderError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
