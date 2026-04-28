import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/order.dart';
import '../../blocs/order/order_bloc.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  OrderStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(AppConstants.kSessionKey);
    if (userId != null && mounted) {
      context.read<OrderBloc>().add(OrderLoadAll(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои заказы'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: [
                _StatusChip(
                  label: 'Все',
                  selected: _selectedStatus == null,
                  onTap: () {
                    setState(() => _selectedStatus = null);
                    context
                        .read<OrderBloc>()
                        .add(const OrderFilterByStatus(null));
                  },
                ),
                const SizedBox(width: 8),
                ...OrderStatus.values.map((s) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _StatusChip(
                        label: s.label,
                        selected: _selectedStatus == s,
                        onTap: () {
                          setState(() => _selectedStatus = s);
                          context.read<OrderBloc>().add(OrderFilterByStatus(s));
                        },
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: BlocBuilder<OrderBloc, OrderState>(
              builder: (context, state) {
                if (state is OrderLoading || state is OrderInitial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is OrderError) {
                  return Center(child: Text('Ошибка: ${state.message}'));
                }
                if (state is OrderLoaded) {
                  if (state.orders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined,
                              size: 96,
                              color: Theme.of(context).colorScheme.outline),
                          const SizedBox(height: 16),
                          Text('Заказов пока нет',
                              style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.orders.length,
                    itemBuilder: (context, index) =>
                        _OrderCard(order: state.orders[index]),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final OrderEntity order;

  Color _statusColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return switch (order.status) {
      OrderStatus.pending => cs.tertiary,
      OrderStatus.confirmed => cs.primary,
      OrderStatus.delivered => cs.secondary,
      OrderStatus.cancelled => cs.error,
    };
  }

  IconData _statusIcon() => switch (order.status) {
        OrderStatus.pending => Icons.access_time_rounded,
        OrderStatus.confirmed => Icons.check_circle_outline,
        OrderStatus.delivered => Icons.done_all_rounded,
        OrderStatus.cancelled => Icons.cancel_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Заказ #${order.id}',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon(), size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(order.status.label,
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: statusColor)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            // Список товаров
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.fiber_manual_record,
                          size: 6, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('${item.productName} × ${item.quantity}',
                            style: theme.textTheme.bodyMedium),
                      ),
                      Text('${item.total.toStringAsFixed(0)} ₸',
                          style: theme.textTheme.bodyMedium),
                    ],
                  ),
                )),
            const Divider(height: 16),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 14, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                    '${order.createdAt.day.toString().padLeft(2, '0')}.${order.createdAt.month.toString().padLeft(2, '0')}.${order.createdAt.year}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const Spacer(),
                Text('Итого: ${order.totalPrice.toStringAsFixed(0)} ₸',
                    style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (order.status == OrderStatus.pending) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmCancel(context),
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('Отменить'),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _confirmDelete(context),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Удалить'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Отменить заказ?'),
        content: Text('Заказ #${order.id} будет отменён.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Нет'),
          ),
          FilledButton(
            onPressed: () {
              context
                  .read<OrderBloc>()
                  .add(OrderUpdateStatus(order.id, OrderStatus.cancelled));
              Navigator.of(context).pop();
            },
            child: const Text('Отменить'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить заказ?'),
        content: Text('Заказ #${order.id} будет удалён из истории.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              context.read<OrderBloc>().add(OrderDelete(order.id));
              Navigator.of(context).pop();
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}
