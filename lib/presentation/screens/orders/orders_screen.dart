import 'package:flutter/material.dart';

enum OrderStatus {
  all('Все'),
  pending('Ожидает'),
  confirmed('Подтверждён'),
  delivered('Доставлен');

  final String label;
  const OrderStatus(this.label);
}

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  OrderStatus _selectedStatus = OrderStatus.all;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои заказы'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Фильтр по статусу
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: OrderStatus.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final status = OrderStatus.values[index];
                final isSelected = status == _selectedStatus;
                return FilterChip(
                  label: Text(status.label),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedStatus = status),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Список заказов — заглушка
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 4,
              itemBuilder: (context, index) => _OrderCard(index: index),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final int index;

  const _OrderCard({required this.index});

  static const _mockOrders = [
    ('Молоко фермерское 3.5%', '2 л', '900 ₸', OrderStatus.pending),
    ('Айран домашний', '1 л', '350 ₸', OrderStatus.confirmed),
    ('Құрт сушёный', '500 г', '600 ₸', OrderStatus.delivered),
    ('Творог зернистый', '1 кг', '700 ₸', OrderStatus.delivered),
  ];

  Color _statusColor(BuildContext context, OrderStatus status) {
    final cs = Theme.of(context).colorScheme;
    return switch (status) {
      OrderStatus.pending => cs.tertiary,
      OrderStatus.confirmed => cs.primary,
      OrderStatus.delivered => cs.secondary,
      OrderStatus.all => cs.outline,
    };
  }

  IconData _statusIcon(OrderStatus status) => switch (status) {
        OrderStatus.pending => Icons.access_time_rounded,
        OrderStatus.confirmed => Icons.check_circle_outline,
        OrderStatus.delivered => Icons.done_all_rounded,
        OrderStatus.all => Icons.help_outline,
      };

  @override
  Widget build(BuildContext context) {
    final (name, qty, price, status) = _mockOrders[index % _mockOrders.length];
    final theme = Theme.of(context);
    final statusColor = _statusColor(context, status);

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
                  child: Text(
                    'Заказ #${1000 + index}',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
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
                      Icon(_statusIcon(status), size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(status.label,
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: statusColor)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            Row(
              children: [
                Icon(Icons.inventory_2_outlined,
                    size: 16, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child:
                      Text('$name — $qty', style: theme.textTheme.bodyMedium),
                ),
                Text(price,
                    style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 14, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text('26 апр. 2026',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
