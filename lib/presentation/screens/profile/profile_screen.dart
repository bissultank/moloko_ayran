import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/address.dart';
import '../../../domain/entities/order.dart';
import '../../blocs/address/address_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/order/order_bloc.dart';
import '../../blocs/theme/theme_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userEmail = '';
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(AppConstants.kSessionKey);
    final email = prefs.getString(AppConstants.kUserEmailKey);
    if (mounted && userId != null) {
      setState(() {
        _userId = userId;
        _userEmail = email ?? '';
      });
      context.read<AddressBloc>().add(AddressLoad(userId));
      context.read<OrderBloc>().add(OrderLoadAll(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/${AppConstants.routeCatalog}');
            }
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Шапка профиля
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(Icons.person,
                        size: 40, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 12),
                  Text(_userEmail,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Статистика заказов
          BlocBuilder<OrderBloc, OrderState>(
            builder: (context, state) {
              if (state is OrderLoaded) {
                final activeOrders = state.orders
                    .where((o) => o.status != OrderStatus.cancelled)
                    .toList();
                final totalSpent = activeOrders.fold<double>(
                    0, (sum, o) => sum + o.totalPrice);
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatItem(
                            icon: Icons.receipt_long_outlined,
                            label: 'Заказов',
                            value: '${state.orders.length}',
                          ),
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: theme.colorScheme.outlineVariant,
                        ),
                        Expanded(
                          child: _StatItem(
                            icon: Icons.account_balance_wallet_outlined,
                            label: 'Потрачено',
                            value: '${totalSpent.toStringAsFixed(0)} ₸',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 24),

          // Тема
          Text('Внешний вид',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return Card(
                child: Column(
                  children: [
                    _ThemeOption(
                      icon: Icons.brightness_auto_outlined,
                      label: 'Системная',
                      mode: ThemeMode.system,
                      selected: state.mode == ThemeMode.system,
                    ),
                    const Divider(height: 1),
                    _ThemeOption(
                      icon: Icons.light_mode_outlined,
                      label: 'Светлая',
                      mode: ThemeMode.light,
                      selected: state.mode == ThemeMode.light,
                    ),
                    const Divider(height: 1),
                    _ThemeOption(
                      icon: Icons.dark_mode_outlined,
                      label: 'Тёмная',
                      mode: ThemeMode.dark,
                      selected: state.mode == ThemeMode.dark,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Адреса
          Row(
            children: [
              Text('Адреса доставки',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add_location_alt_outlined),
                onPressed: _userId == null
                    ? null
                    : () => _showAddressDialog(context, _userId!),
              ),
            ],
          ),
          const SizedBox(height: 8),
          BlocBuilder<AddressBloc, AddressState>(
            builder: (context, state) {
              if (state is AddressLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is AddressLoaded) {
                if (state.addresses.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.location_off_outlined,
                              color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text('Нет сохранённых адресов'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Column(
                  children: state.addresses
                      .map((a) => _AddressCard(
                            address: a,
                            userId: _userId!,
                            onEdit: () => _showAddressDialog(context, _userId!,
                                existing: a),
                          ))
                      .toList(),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 32),

          // Кнопка выхода
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error),
            ),
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Выйти из аккаунта'),
          ),
        ],
      ),
    );
  }

  void _showAddressDialog(BuildContext context, int userId,
      {Address? existing}) {
    showDialog(
      context: context,
      builder: (_) => _AddressFormDialog(userId: userId, existing: existing),
    );
  }

  void _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Выйти из аккаунта?'),
        content: const Text('Вы будете перенаправлены на экран входа.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dialogContext).colorScheme.error),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(const AuthLogoutRequested());
      context.go(AppConstants.routeLogin);
    }
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 24),
        const SizedBox(height: 4),
        Text(value,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.mode,
    required this.selected,
  });
  final IconData icon;
  final String label;
  final ThemeMode mode;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(label),
      trailing:
          selected ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
      onTap: () => context.read<ThemeBloc>().add(ThemeChange(mode)),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard(
      {required this.address, required this.userId, required this.onEdit});
  final Address address;
  final int userId;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          address.isDefault ? Icons.location_on : Icons.location_on_outlined,
          color: address.isDefault
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
        ),
        title: Row(
          children: [
            Text(address.label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            if (address.isDefault) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('основной',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: theme.colorScheme.primary)),
              ),
            ],
          ],
        ),
        subtitle: Text(address.full),
        trailing: PopupMenuButton<String>(
          itemBuilder: (_) => [
            if (!address.isDefault)
              const PopupMenuItem(
                  value: 'default', child: Text('Сделать основным')),
            const PopupMenuItem(value: 'edit', child: Text('Редактировать')),
            const PopupMenuItem(value: 'delete', child: Text('Удалить')),
          ],
          onSelected: (action) {
            switch (action) {
              case 'default':
                context
                    .read<AddressBloc>()
                    .add(AddressSetDefault(userId, address.id));
              case 'edit':
                onEdit();
              case 'delete':
                context.read<AddressBloc>().add(AddressDelete(address.id));
            }
          },
        ),
      ),
    );
  }
}

class _AddressFormDialog extends StatefulWidget {
  const _AddressFormDialog({required this.userId, this.existing});
  final int userId;
  final Address? existing;

  @override
  State<_AddressFormDialog> createState() => _AddressFormDialogState();
}

class _AddressFormDialogState extends State<_AddressFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _streetController;
  late final TextEditingController _apartmentController;
  late final TextEditingController _cityController;
  late bool _isDefault;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _labelController = TextEditingController(text: e?.label ?? 'Дом');
    _streetController = TextEditingController(text: e?.street ?? '');
    _apartmentController = TextEditingController(text: e?.apartment ?? '');
    _cityController = TextEditingController(text: e?.city ?? 'Алматы');
    _isDefault = e?.isDefault ?? false;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _streetController.dispose();
    _apartmentController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final address = Address(
      id: widget.existing?.id ?? 0,
      userId: widget.userId,
      label: _labelController.text.trim(),
      street: _streetController.text.trim(),
      apartment: _apartmentController.text.trim(),
      city: _cityController.text.trim(),
      isDefault: _isDefault,
    );

    if (widget.existing == null) {
      context.read<AddressBloc>().add(AddressCreate(address));
    } else {
      context.read<AddressBloc>().add(AddressUpdate(address));
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Новый адрес' : 'Редактирование'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _labelController,
                decoration:
                    const InputDecoration(labelText: 'Название (Дом, Работа)'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Введите название' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'Город'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Введите город' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _streetController,
                decoration: const InputDecoration(labelText: 'Улица и дом'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Введите улицу' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _apartmentController,
                decoration: const InputDecoration(
                    labelText: 'Квартира, этаж (необязательно)'),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Сделать основным'),
                value: _isDefault,
                onChanged: (v) => setState(() => _isDefault = v ?? false),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}
