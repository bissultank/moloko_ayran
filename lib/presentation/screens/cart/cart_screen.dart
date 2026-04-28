import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/order.dart';
import '../../blocs/cart/cart_bloc.dart';
import '../../blocs/order/order_bloc.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Корзина'),
        centerTitle: false,
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Очистить корзину',
                onPressed: () =>
                    context.read<CartBloc>().add(const CartClear()),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 96, color: Theme.of(context).colorScheme.outline),
                  const SizedBox(height: 16),
                  Text('Корзина пустая',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Добавьте продукты из каталога',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
            );
          }

          final lines = state.lines;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: lines.length,
                  itemBuilder: (context, index) =>
                      _CartLineCard(line: lines[index]),
                ),
              ),
              _CheckoutPanel(
                  totalPrice: state.totalPrice, totalItems: state.totalItems),
            ],
          );
        },
      ),
    );
  }
}

class _CartLineCard extends StatelessWidget {
  const _CartLineCard({required this.line});
  final CartLine line;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.water_drop_outlined,
                  color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(line.product.name,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(
                      '${line.product.price.toStringAsFixed(0)} ₸/${line.product.unit}',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text('${line.total.toStringAsFixed(0)} ₸',
                      style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 18),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => context
                        .read<CartBloc>()
                        .add(CartDecrement(line.product.id)),
                  ),
                  Text('${line.quantity}',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => context
                        .read<CartBloc>()
                        .add(CartIncrement(line.product.id)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutPanel extends StatelessWidget {
  const _CheckoutPanel({required this.totalPrice, required this.totalItems});
  final double totalPrice;
  final int totalItems;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, -2)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Итого ($totalItems товаров)',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                      Text('${totalPrice.toStringAsFixed(0)} ₸',
                          style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary)),
                    ],
                  ),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 52),
                      padding: const EdgeInsets.symmetric(horizontal: 24)),
                  onPressed: () => _placeOrder(context),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Оформить'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _placeOrder(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(AppConstants.kSessionKey);
    if (userId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка: войдите в аккаунт')),
        );
      }
      return;
    }

    if (!context.mounted) return;

    final cartState = context.read<CartBloc>().state;
    final orderItems = cartState.lines
        .map((l) => OrderItem(
              productId: l.product.id,
              productName: l.product.name,
              category: l.product.category.name,
              price: l.product.price,
              unit: l.product.unit,
              quantity: l.quantity,
            ))
        .toList();

    final order = OrderEntity(
      id: 0,
      userId: userId,
      items: orderItems,
      totalPrice: cartState.totalPrice,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
    );

    context.read<OrderBloc>().add(OrderCreate(order));
    context.read<CartBloc>().add(const CartClear());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Заказ оформлен!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
