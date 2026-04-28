part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

class CartLoad extends CartEvent {
  const CartLoad();
}

class CartAdd extends CartEvent {
  const CartAdd(this.product, {this.quantity = 1});
  final Product product;
  final int quantity;
  @override
  List<Object?> get props => [product, quantity];
}

class CartRemove extends CartEvent {
  const CartRemove(this.productId);
  final int productId;
  @override
  List<Object?> get props => [productId];
}

class CartIncrement extends CartEvent {
  const CartIncrement(this.productId);
  final int productId;
  @override
  List<Object?> get props => [productId];
}

class CartDecrement extends CartEvent {
  const CartDecrement(this.productId);
  final int productId;
  @override
  List<Object?> get props => [productId];
}

class CartClear extends CartEvent {
  const CartClear();
}
