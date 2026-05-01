import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/product_visuals.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/entities/product.dart';
import '../../blocs/order/order_bloc.dart';
import '../../widgets/product_image.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final id = int.tryParse(orderId) ?? 0;

    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        OrderEntity? order;
        if (state is OrderLoaded) {
          for (final o in state.orders) {
            if (o.id == id) {
              order = o;
              break;
            }
          }
        }

        if (order == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Заказ')),
            body: const Center(child: Text('Заказ не найден')),
          );
        }

        final theme = Theme.of(context);
        final o = order;

        return Scaffold(
          appBar: AppBar(
            title: Text('Заказ #${o.id}'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _StatusBadge(status: o.status),
              const SizedBox(height: 20),

              // Адрес доставки
              if (o.addressFull.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.location_on_outlined,
                              color: theme.colorScheme.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(o.addressLabel,
                                  style: theme.textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(o.addressFull,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                      color:
                                          theme.colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Дата
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        '${o.createdAt.day.toString().padLeft(2, '0')}.${o.createdAt.month.toString().padLeft(2, '0')}.${o.createdAt.year} в ${o.createdAt.hour.toString().padLeft(2, '0')}:${o.createdAt.minute.toString().padLeft(2, '0')}',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Товары
              Text('Товары (${o.items.length})',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ...o.items.map((item) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ProductImage(
                            category: ProductVisuals.categoryFromString(
                                item.category),
                            size: 48,
                            emojiSize: 24,
                            borderRadius: 12,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.productName,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                Text(
                                    '${item.price.toStringAsFixed(0)} ₸/${item.unit} × ${item.quantity}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme
                                            .colorScheme.onSurfaceVariant)),
                              ],
                            ),
                          ),
                          Text('${item.total.toStringAsFixed(0)} ₸',
                              style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary)),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 16),

              // Итого
              Card(
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text('Итого',
                          style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onPrimaryContainer)),
                      const Spacer(),
                      Text('${o.totalPrice.toStringAsFixed(0)} ₸',
                          style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Действия
              if (o.status == OrderStatus.pending) ...[
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: () => _confirmCancel(context, o),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Отменить заказ'),
                ),
                const SizedBox(height: 8),
              ],
              TextButton.icon(
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  foregroundColor: theme.colorScheme.error,
                ),
                onPressed: () => _confirmDelete(context, o),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Удалить из истории'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmCancel(BuildContext context, OrderEntity order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Отменить заказ?'),
        content: Text('Заказ #${order.id} будет отменён.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Нет'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Отменить'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context
          .read<OrderBloc>()
          .add(OrderUpdateStatus(order.id, OrderStatus.cancelled));
      context.pop();
    }
  }

  void _confirmDelete(BuildContext context, OrderEntity order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить заказ?'),
        content: Text('Заказ #${order.id} будет удалён из истории.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dialogContext).colorScheme.error),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<OrderBloc>().add(OrderDelete(order.id));
      context.pop();
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = switch (status) {
      OrderStatus.pending => cs.tertiary,
      OrderStatus.confirmed => cs.primary,
      OrderStatus.delivered => cs.secondary,
      OrderStatus.cancelled => cs.error,
    };
    final icon = switch (status) {
      OrderStatus.pending => Icons.access_time_rounded,
      OrderStatus.confirmed => Icons.check_circle_outline,
      OrderStatus.delivered => Icons.done_all_rounded,
      OrderStatus.cancelled => Icons.cancel_outlined,
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Статус заказа',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
              Text(status.label,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}
