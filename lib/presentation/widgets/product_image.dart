// Слой: presentation | Назначение: переиспользуемый виджет с градиентом и emoji продукта

import 'package:flutter/material.dart';

import '../../core/theme/product_visuals.dart';
import '../../domain/entities/product.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.category,
    this.size = 56,
    this.emojiSize,
    this.borderRadius = 16,
  });

  final ProductCategory category;
  final double size;
  final double? emojiSize;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: ProductVisuals.gradient(category),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          ProductVisuals.emoji(category),
          style: TextStyle(fontSize: emojiSize ?? size * 0.5),
        ),
      ),
    );
  }
}

/// Большой hero-блок продукта (для деталей продукта)
class ProductHero extends StatelessWidget {
  const ProductHero({
    super.key,
    required this.category,
    this.height = 240,
  });

  final ProductCategory category;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: ProductVisuals.gradient(category),
      ),
      child: Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              ProductVisuals.emoji(category),
              style: const TextStyle(fontSize: 64),
            ),
          ),
        ),
      ),
    );
  }
}
