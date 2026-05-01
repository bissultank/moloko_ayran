import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/order.dart';
import '../../blocs/order/order_bloc.dart';
import '../../widgets/empty_state.dart';

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

  Future<void> _refresh() async {
    await _loadOrders();
    await Future.delayed(const Duration(milliseconds: 500));
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
                  return EmptyState(
                    icon: Icons.error_outline,
                    title: 'Ошибка',
                    subtitle: state.message,
                  );
                }
                if (state is OrderLoaded) {
                  if (state.orders.isEmpty) {
                    return EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'Заказов пока нет',
                      subtitle: 'Перейдите в каталог и оформите первый заказ',
                      actionLabel: 'В каталог',
                      onAction: () =>
                          context.go('/${AppConstants.routeCatalog}'),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.orders.length,
                      itemBuilder: (context, index) =>
                          _OrderCard(order: state.orders[index]),
                    ),
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
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/order/${order.id}'),
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
              const SizedBox(height: 8),
              Text('${order.items.length} ${_itemsWord(order.items.length)}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 14, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                      '${order.createdAt.day.toString().padLeft(2, '0')}.${order.createdAt.month.toString().padLeft(2, '0')}.${order.createdAt.year}',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                  const Spacer(),
                  Text('${order.totalPrice.toStringAsFixed(0)} ₸',
                      style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _itemsWord(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'товар';
    if ((count % 10 >= 2 && count % 10 <= 4) &&
        (count % 100 < 10 || count % 100 >= 20)) {
      return 'товара';
    }
    return 'товаров';
  }
}
