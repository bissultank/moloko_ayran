import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/entities/product.dart';
import '../../blocs/order/order_bloc.dart';
import '../../widgets/empty_state.dart';
import 'package:go_router/go_router.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
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
        title: const Text('Аналитика'),
        centerTitle: false,
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading || state is OrderInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is OrderLoaded) {
            return _buildContent(context, state.orders);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<OrderEntity> orders) {
    final theme = Theme.of(context);

    final Map<String, double> byCategory = {};
    double totalSpent = 0;

    for (final order in orders) {
      if (order.status == OrderStatus.cancelled) continue;
      for (final item in order.items) {
        byCategory[item.category] =
            (byCategory[item.category] ?? 0) + item.total;
        totalSpent += item.total;
      }
    }

    if (byCategory.isEmpty) {
      return EmptyState(
        icon: Icons.bar_chart_outlined,
        title: 'Нет данных для аналитики',
        subtitle:
            'Сделайте первый заказ — и здесь появится статистика расходов',
        actionLabel: 'В каталог',
        onAction: () => context.go('/${AppConstants.routeCatalog}'),
      );
    }

    final entries = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxY = entries.first.value * 1.2;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Главная карточка
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet_outlined,
                          color: theme.colorScheme.onPrimary),
                      const SizedBox(width: 8),
                      Text('Всего потрачено',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimary
                                  .withOpacity(0.85))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${totalSpent.toStringAsFixed(0)} ₸',
                      style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimary)),
                  const SizedBox(height: 8),
                  Text('За ${orders.length} ${_ordersWord(orders.length)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color:
                              theme.colorScheme.onPrimary.withOpacity(0.75))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Расходы по категориям',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => theme.colorScheme.inverseSurface,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                          BarTooltipItem(
                        '${_categoryLabel(entries[group.x].key)}\n${rod.toY.toStringAsFixed(0)} ₸',
                        TextStyle(
                            color: theme.colorScheme.onInverseSurface,
                            fontSize: 12),
                      ),
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= entries.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              _categoryLabel(entries[index].key),
                              style: theme.textTheme.labelSmall,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: theme.colorScheme.outlineVariant,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(entries.length, (i) {
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: entries[i].value,
                          color: theme.colorScheme.primary,
                          width: 32,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8)),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Детализация',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...entries.map((e) {
              final percent = (e.value / totalSpent * 100).toStringAsFixed(1);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(Icons.label_important_outline,
                        size: 18, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_categoryLabel(e.key))),
                    Text('$percent%',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(width: 12),
                    Text('${e.value.toStringAsFixed(0)} ₸',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _categoryLabel(String key) => ProductCategory.fromString(key).label;

  String _ordersWord(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'заказ';
    if ((count % 10 >= 2 && count % 10 <= 4) &&
        (count % 100 < 10 || count % 100 >= 20)) {
      return 'заказа';
    }
    return 'заказов';
  }
}
