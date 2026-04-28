import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/product.dart';
import '../../blocs/cart/cart_bloc.dart';
import '../../blocs/product/product_bloc.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final id = int.tryParse(widget.productId) ?? 0;

    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        Product? product;
        if (state is ProductLoaded) {
          for (final p in state.products) {
            if (p.id == id) {
              product = p;
              break;
            }
          }
        }

        if (product == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Продукт не найден')),
          );
        }

        final p = product;
        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Продукт'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 220,
                  color: theme.colorScheme.primaryContainer,
                  child: Icon(Icons.water_drop_rounded,
                      size: 80, color: theme.colorScheme.primary),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Chip(
                        label: Text(p.category.label),
                        backgroundColor: theme.colorScheme.secondaryContainer,
                      ),
                      const SizedBox(height: 8),
                      Text(p.name,
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.agriculture_outlined,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(p.farmer,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text('Характеристики',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      _InfoRow(
                          label: 'Цена за ${p.unit}',
                          value: '${p.price.toStringAsFixed(0)} ₸'),
                      _InfoRow(label: 'Категория', value: p.category.label),
                      _InfoRow(label: 'Ферма', value: p.farmer),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  // Счётчик количества
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outline),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: _quantity > 1
                              ? () => setState(() => _quantity--)
                              : null,
                        ),
                        Text('$_quantity',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => setState(() => _quantity++),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 52)),
                      onPressed: () {
                        context
                            .read<CartBloc>()
                            .add(CartAdd(p, quantity: _quantity));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Добавлено в корзину: $_quantity × ${p.name}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        context.pop();
                      },
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: Text(
                          'В корзину · ${(p.price * _quantity).toStringAsFixed(0)} ₸'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
          Text(value,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
