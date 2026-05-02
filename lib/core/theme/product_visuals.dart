// Слой: core | Назначение: визуальный стиль для категорий продуктов

import 'package:flutter/material.dart';

import '../../domain/entities/product.dart';

class ProductVisuals {
  ProductVisuals._();

  static LinearGradient gradient(ProductCategory category) {
    switch (category) {
      case ProductCategory.milk:
        return const LinearGradient(
          colors: [Color(0xFF74EBD5), Color(0xFFACB6E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ProductCategory.ayran:
        return const LinearGradient(
          colors: [Color(0xFFE0EAFC), Color(0xFFCFDEF3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ProductCategory.kefir:
        return const LinearGradient(
          colors: [Color(0xFFA8EDEA), Color(0xFFFED6E3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ProductCategory.smetana:
        return const LinearGradient(
          colors: [Color(0xFFFFE0B2), Color(0xFFFFCC80)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ProductCategory.tvorog:
        return const LinearGradient(
          colors: [Color(0xFFFFF59D), Color(0xFFFFE082)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ProductCategory.butter:
        return const LinearGradient(
          colors: [Color(0xFFFFE082), Color(0xFFFFB74D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ProductCategory.cheese:
        return const LinearGradient(
          colors: [Color(0xFFFFCC80), Color(0xFFFF8A65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ProductCategory.yogurt:
        return const LinearGradient(
          colors: [Color(0xFFCE93D8), Color(0xFF9FA8DA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ProductCategory.kaymak:
        return const LinearGradient(
          colors: [Color(0xFFFFD180), Color(0xFFFFAB91)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ProductCategory.other:
        return const LinearGradient(
          colors: [Color(0xFFA5D6A7), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  static String emoji(ProductCategory category) {
    switch (category) {
      case ProductCategory.milk:
        return '🥛';
      case ProductCategory.ayran:
        return '🍶';
      case ProductCategory.kefir:
        return '🍶';
      case ProductCategory.smetana:
        return '🥣';
      case ProductCategory.tvorog:
        return '🍚';
      case ProductCategory.butter:
        return '🧈';
      case ProductCategory.cheese:
        return '🧀';
      case ProductCategory.yogurt:
        return '🍦';
      case ProductCategory.kaymak:
        return '🥣';
      case ProductCategory.other:
        return '⚪';
    }
  }

  static ProductCategory categoryFromString(String value) {
    return ProductCategory.fromString(value);
  }
}
