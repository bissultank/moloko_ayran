// Слой: presentation | Назначение: CartBloc — корзина с сохранением в Drift

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/datasources/cart_local_datasource.dart';
import '../../../domain/entities/product.dart';
import 'cart_line.dart';

export 'cart_line.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc(this._datasource) : super(const CartState(items: {})) {
    on<CartLoad>(_onLoad);
    on<CartAdd>(_onAdd);
    on<CartRemove>(_onRemove);
    on<CartIncrement>(_onIncrement);
    on<CartDecrement>(_onDecrement);
    on<CartClear>(_onClear);
  }

  final CartLocalDatasource _datasource;

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(AppConstants.kSessionKey);
  }

  Future<void> _onLoad(CartLoad event, Emitter<CartState> emit) async {
    final userId = await _getUserId();
    if (userId == null) return;
    final lines = await _datasource.getByUserId(userId);
    final map = {for (var l in lines) l.product.id: l};
    emit(CartState(items: map));
  }

  Future<void> _onAdd(CartAdd event, Emitter<CartState> emit) async {
    final userId = await _getUserId();
    if (userId == null) return;
    await _datasource.addOrIncrement(userId, event.product, event.quantity);
    add(const CartLoad());
  }

  Future<void> _onRemove(CartRemove event, Emitter<CartState> emit) async {
    final userId = await _getUserId();
    if (userId == null) return;
    await _datasource.removeByProduct(userId, event.productId);
    add(const CartLoad());
  }

  Future<void> _onIncrement(
      CartIncrement event, Emitter<CartState> emit) async {
    final userId = await _getUserId();
    if (userId == null) return;
    final existing = state.items[event.productId];
    if (existing != null) {
      await _datasource.setQuantity(
          userId, event.productId, existing.quantity + 1);
      add(const CartLoad());
    }
  }

  Future<void> _onDecrement(
      CartDecrement event, Emitter<CartState> emit) async {
    final userId = await _getUserId();
    if (userId == null) return;
    final existing = state.items[event.productId];
    if (existing != null) {
      await _datasource.setQuantity(
          userId, event.productId, existing.quantity - 1);
      add(const CartLoad());
    }
  }

  Future<void> _onClear(CartClear event, Emitter<CartState> emit) async {
    final userId = await _getUserId();
    if (userId == null) return;
    await _datasource.clearByUser(userId);
    emit(const CartState(items: {}));
  }
}
