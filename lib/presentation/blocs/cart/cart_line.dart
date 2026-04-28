// Слой: presentation | Назначение: модель строки корзины

import 'package:equatable/equatable.dart';

import '../../../domain/entities/product.dart';

class CartLine extends Equatable {
  const CartLine({required this.product, required this.quantity});
  final Product product;
  final int quantity;

  double get total => product.price * quantity;

  CartLine copyWith({Product? product, int? quantity}) => CartLine(
      product: product ?? this.product, quantity: quantity ?? this.quantity);

  @override
  List<Object?> get props => [product, quantity];
}
