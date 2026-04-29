import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/address.dart';
import '../../../domain/entities/order.dart';
import '../../blocs/address/address_bloc.dart';
import '../../blocs/cart/cart_bloc.dart';
import '../../blocs/order/order_bloc.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Address? _selectedAddress;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(AppConstants.kSessionKey);
    if (userId != null && mounted) {
      setState(() => _userId = userId);
      context.read<AddressBloc>().add(AddressLoad(userId));
    }
  }

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
        builder: (context, cartState) {
          if (cartState.isEmpty) {
            return _EmptyCart(
                onShop: () => context.go('/${AppConstants.routeCatalog}'));
          }

          final lines = cartState.lines;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Селектор адреса
                    BlocBuilder<AddressBloc, AddressState>(
                      builder: (context, addrState) {
                        if (addrState is AddressLoaded) {
                          // Если выбранного нет — берём default
                          _selectedAddress ??= addrState.defaultAddress;
                          return _AddressSelector(
                            addresses: addrState.addresses,
                            selected: _selectedAddress,
                            onSelect: (a) =>
                                setState(() => _selectedAddress = a),
                            userId: _userId,
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 16),
                    Text('Товары',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ...lines.map((line) => _CartLineCard(line: line)),
                  ],
                ),
              ),
              _CheckoutPanel(
                totalPrice: cartState.totalPrice,
                totalItems: cartState.totalItems,
                selectedAddress: _selectedAddress,
                userId: _userId,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onShop});
  final VoidCallback onShop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined,
                size: 96, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text('Корзина пустая', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Добавьте продукты из каталога',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onShop,
              icon: const Icon(Icons.storefront_outlined),
              label: const Text('Перейти в каталог'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressSelector extends StatelessWidget {
  const _AddressSelector({
    required this.addresses,
    required this.selected,
    required this.onSelect,
    required this.userId,
  });
  final List<Address> addresses;
  final Address? selected;
  final ValueChanged<Address> onSelect;
  final int? userId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showPicker(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.location_on_outlined,
                  color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Адрес доставки',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 2),
                    Text(
                      selected != null
                          ? '${selected!.label} · ${selected!.full}'
                          : 'Не выбран',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    if (addresses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Сначала добавьте адрес в профиле'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Выберите адрес',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            ...addresses.map((a) => ListTile(
                  leading: Icon(
                    selected?.id == a.id
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(a.label),
                  subtitle: Text(a.full),
                  onTap: () {
                    onSelect(a);
                    Navigator.of(context).pop();
                  },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _CartLineCard extends StatelessWidget {
  const _CartLineCard({required this.line});
  final dynamic line;

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
  const _CheckoutPanel({
    required this.totalPrice,
    required this.totalItems,
    required this.selectedAddress,
    required this.userId,
  });

  final double totalPrice;
  final int totalItems;
  final Address? selectedAddress;
  final int? userId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canCheckout = selectedAddress != null && userId != null;

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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
              onPressed: canCheckout ? () => _placeOrder(context) : null,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Оформить'),
            ),
          ],
        ),
      ),
    );
  }

  void _placeOrder(BuildContext context) {
    if (userId == null || selectedAddress == null) return;

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
      userId: userId!,
      items: orderItems,
      totalPrice: cartState.totalPrice,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
    );

    context.read<OrderBloc>().add(OrderCreate(order));
    context.read<CartBloc>().add(const CartClear());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Заказ оформлен на адрес ${selectedAddress!.label}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
