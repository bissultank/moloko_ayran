part of 'cart_bloc.dart';

class CartState extends Equatable {
  const CartState({required this.items});
  final Map<int, CartLine> items;

  int get totalItems =>
      items.values.fold(0, (sum, line) => sum + line.quantity);
  double get totalPrice =>
      items.values.fold(0.0, (sum, line) => sum + line.total);
  bool get isEmpty => items.isEmpty;
  List<CartLine> get lines => items.values.toList();

  @override
  List<Object?> get props => [items];
}
