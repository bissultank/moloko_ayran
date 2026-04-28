// Слой: domain | Назначение: сущность заказа

import 'package:equatable/equatable.dart';

enum OrderStatus {
  pending('Ожидает'),
  confirmed('Подтверждён'),
  delivered('Доставлен'),
  cancelled('Отменён');

  final String label;
  const OrderStatus(this.label);

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => OrderStatus.pending,
    );
  }
}

// Один товар внутри заказа (хранится в JSON в БД)
class OrderItem extends Equatable {
  const OrderItem({
    required this.productId,
    required this.productName,
    required this.category,
    required this.price,
    required this.unit,
    required this.quantity,
  });

  final int productId;
  final String productName;
  final String category;
  final double price;
  final String unit;
  final int quantity;

  double get total => price * quantity;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'category': category,
        'price': price,
        'unit': unit,
        'quantity': quantity,
      };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        productId: json['productId'] as int,
        productName: json['productName'] as String,
        category: json['category'] as String,
        price: (json['price'] as num).toDouble(),
        unit: json['unit'] as String,
        quantity: json['quantity'] as int,
      );

  @override
  List<Object?> get props =>
      [productId, productName, category, price, unit, quantity];
}

class OrderEntity extends Equatable {
  const OrderEntity({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final int userId;
  final List<OrderItem> items;
  final double totalPrice;
  final OrderStatus status;
  final DateTime createdAt;

  OrderEntity copyWith({
    int? id,
    int? userId,
    List<OrderItem>? items,
    double? totalPrice,
    OrderStatus? status,
    DateTime? createdAt,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, items, totalPrice, status, createdAt];
}
