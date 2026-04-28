// Слой: domain | Назначение: чистая сущность продукта

import 'package:equatable/equatable.dart';

enum ProductCategory {
  milk('Молоко'),
  ayran('Айран'),
  kefir('Кефир'),
  smetana('Сметана'),
  tvorog('Творог'),
  butter('Масло'),
  cheese('Сыр'),
  yogurt('Йогурт'),
  other('Другое');

  final String label;
  const ProductCategory(this.label);

  static ProductCategory fromString(String value) {
    return ProductCategory.values.firstWhere(
      (c) => c.name == value,
      orElse: () => ProductCategory.other,
    );
  }
}

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.unit,
    required this.farmer,
    required this.description,
    required this.isAvailable,
  });

  final int id;
  final String name;
  final ProductCategory category;
  final double price;
  final String unit; // л, кг, шт
  final String farmer;
  final String description;
  final bool isAvailable;

  Product copyWith({
    int? id,
    String? name,
    ProductCategory? category,
    double? price,
    String? unit,
    String? farmer,
    String? description,
    bool? isAvailable,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      farmer: farmer ?? this.farmer,
      description: description ?? this.description,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, category, price, unit, farmer, description, isAvailable];
}
