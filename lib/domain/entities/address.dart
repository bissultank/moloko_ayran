// Слой: domain | Назначение: сущность адреса доставки

import 'package:equatable/equatable.dart';

class Address extends Equatable {
  const Address({
    required this.id,
    required this.userId,
    required this.label,
    required this.street,
    required this.apartment,
    required this.city,
    this.isDefault = false,
  });

  final int id;
  final int userId;
  final String label; // "Дом", "Работа"
  final String street; // "ул. Абая 150"
  final String apartment; // "квартира 25, 4 этаж"
  final String city; // "Алматы"
  final bool isDefault;

  String get full =>
      '$city, $street${apartment.isNotEmpty ? ', $apartment' : ''}';

  Address copyWith({
    int? id,
    int? userId,
    String? label,
    String? street,
    String? apartment,
    String? city,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      street: street ?? this.street,
      apartment: apartment ?? this.apartment,
      city: city ?? this.city,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  List<Object?> get props =>
      [id, userId, label, street, apartment, city, isDefault];
}
