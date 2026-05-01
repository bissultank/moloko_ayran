import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/product.dart';
import '../../blocs/cart/cart_bloc.dart';
import '../../blocs/product/product_bloc.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/product_image.dart';
import '../../widgets/product_skeleton.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  ProductCategory? _selectedCategory;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    context.read<ProductBloc>().add(const ProductLoadAll());
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Каталог'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Профиль',
            onPressed: () => context.push(AppConstants.routeProfile),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Поиск продуктов...',
              leading: const Icon(Icons.search),
              onChanged: (value) =>
                  context.read<ProductBloc>().add(ProductSearch(value)),
              padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 16)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: [
                _CategoryChip(
                  label: 'Все',
                  selected: _selectedCategory == null,
                  onTap: () {
                    setState(() => _selectedCategory = null);
                    context
                        .read<ProductBloc>()
                        .add(const ProductFilterByCategory(null));
                  },
                ),
                const SizedBox(width: 8),
                ...ProductCategory.values.map((c) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _CategoryChip(
                        label: c.label,
                        selected: _selectedCategory == c,
                        onTap: () {
                          setState(() => _selectedCategory = c);
                          context
                              .read<ProductBloc>()
                              .add(ProductFilterByCategory(c));
                        },
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading || state is ProductInitial) {
                  return const ProductSkeletonList();
                }
                if (state is ProductError) {
                  return EmptyState(
                    icon: Icons.error_outline,
                    title: 'Что-то пошло не так',
                    subtitle: state.message,
                    actionLabel: 'Повторить',
                    onAction: _refresh,
                  );
                }
                if (state is ProductLoaded) {
                  if (state.products.isEmpty) {
                    return const EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'Продукты не найдены',
                      subtitle:
                          'Попробуйте изменить фильтр или поисковый запрос',
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.products.length,
                      itemBuilder: (context, index) {
                        final product = state.products[index];
                        return _ProductCard(product: product);
                      },
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

class _CategoryChip extends StatelessWidget {
  const _CategoryChip(
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

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/catalog/product/${product.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ProductImage(category: product.category),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('${product.category.label} · ${product.farmer}',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text(
                        '${product.price.toStringAsFixed(0)} ₸/${product.unit}',
                        style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              IconButton.filled(
                icon: const Icon(Icons.add_shopping_cart),
                tooltip: 'В корзину',
                onPressed: () {
                  context.read<CartBloc>().add(CartAdd(product));
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('${product.name} добавлен',
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                        action: SnackBarAction(
                          label: 'В корзину',
                          textColor: Colors.white,
                          onPressed: () =>
                              context.go('/${AppConstants.routeCart}'),
                        ),
                      ),
                    );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
