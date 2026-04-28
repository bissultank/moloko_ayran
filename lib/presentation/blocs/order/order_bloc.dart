// Слой: presentation | Назначение: OrderBloc — управление заказами

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/order.dart';
import '../../../domain/usecases/order_usecases.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc({
    required GetUserOrdersUseCase getUserOrdersUseCase,
    required GetOrdersByStatusUseCase getByStatusUseCase,
    required CreateOrderUseCase createUseCase,
    required UpdateOrderStatusUseCase updateStatusUseCase,
    required DeleteOrderUseCase deleteUseCase,
  })  : _getUserOrdersUseCase = getUserOrdersUseCase,
        _getByStatusUseCase = getByStatusUseCase,
        _createUseCase = createUseCase,
        _updateStatusUseCase = updateStatusUseCase,
        _deleteUseCase = deleteUseCase,
        super(const OrderInitial()) {
    on<OrderLoadAll>(_onLoadAll);
    on<OrderFilterByStatus>(_onFilterByStatus);
    on<OrderCreate>(_onCreate);
    on<OrderUpdateStatus>(_onUpdateStatus);
    on<OrderDelete>(_onDelete);
  }

  final GetUserOrdersUseCase _getUserOrdersUseCase;
  final GetOrdersByStatusUseCase _getByStatusUseCase;
  final CreateOrderUseCase _createUseCase;
  final UpdateOrderStatusUseCase _updateStatusUseCase;
  final DeleteOrderUseCase _deleteUseCase;

  int? _currentUserId;

  Future<void> _onLoadAll(OrderLoadAll event, Emitter<OrderState> emit) async {
    _currentUserId = event.userId;
    emit(const OrderLoading());
    try {
      final orders = await _getUserOrdersUseCase(event.userId);
      emit(OrderLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onFilterByStatus(
      OrderFilterByStatus event, Emitter<OrderState> emit) async {
    if (_currentUserId == null) return;
    emit(const OrderLoading());
    try {
      final orders = event.status == null
          ? await _getUserOrdersUseCase(_currentUserId!)
          : await _getByStatusUseCase(_currentUserId!, event.status!);
      emit(OrderLoaded(orders, selectedStatus: event.status));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onCreate(OrderCreate event, Emitter<OrderState> emit) async {
    try {
      await _createUseCase(event.order);
      if (_currentUserId != null) {
        add(OrderLoadAll(_currentUserId!));
      }
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onUpdateStatus(
      OrderUpdateStatus event, Emitter<OrderState> emit) async {
    try {
      await _updateStatusUseCase(event.orderId, event.status);
      if (_currentUserId != null) add(OrderLoadAll(_currentUserId!));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onDelete(OrderDelete event, Emitter<OrderState> emit) async {
    try {
      await _deleteUseCase(event.orderId);
      if (_currentUserId != null) add(OrderLoadAll(_currentUserId!));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }
}
