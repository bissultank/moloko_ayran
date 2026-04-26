import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Категории продуктов — временно здесь, потом переедет в domain/entities
enum ProductCategory {
  all('Все', Icons.grid_view_rounded),
  milk('Молоко', Icons.water_drop_outlined),
  ayran('Айран', Icons.local_drink_outlined),
  kurt('Құрт', Icons.circle_outlined),
  smetana('Сметана', Icons.opacity_outlined),
  tvorog('Творог', Icons.square_outlined),
  kaymak('Қаймақ', Icons.blur_circular_outlined),
  shubat('Шұбат', Icons.wine_bar_outlined);

  final String label;
  final IconData icon;
  const ProductCategory(this.label, this.icon);
}

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  ProductCategory _selectedCategory = ProductCategory.all;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Каталог'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {}, // TODO: профиль
          ),
        ],
      ),
      body: Column(
        children: [
          // Поиск
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Поиск продуктов...',
              leading: const Icon(Icons.search),
              onChanged: (value) => setState(() {}),
              padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 16)),
            ),
          ),
          const SizedBox(height: 12),

          // Фильтр по категории
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: ProductCategory.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = ProductCategory.values[index];
                final isSelected = category == _selectedCategory;
                return FilterChip(
                  label: Text(category.label),
                  avatar: Icon(category.icon, size: 16),
                  selected: isSelected,
                  onSelected: (_) =>
                      setState(() => _selectedCategory = category),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Список продуктов — заглушка
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 8,
              itemBuilder: (context, index) {
                return _ProductCard(
                  index: index,
                  onTap: () => context.go('/catalog/product/$index'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final int index;
  final VoidCallback onTap;

  const _ProductCard({required this.index, required this.onTap});

  static const _mockProducts = [
    (
      'Молоко фермерское 3.5%',
      'Молоко',
      '450 ₸ / л',
      Icons.water_drop_outlined
    ),
    ('Айран домашний', 'Айран', '350 ₸ / л', Icons.local_drink_outlined),
    ('Құрт сушёный', 'Құрт', '1200 ₸ / кг', Icons.circle_outlined),
    ('Сметана 25%', 'Сметана', '600 ₸ / кг', Icons.opacity_outlined),
    ('Творог зернистый', 'Творог', '700 ₸ / кг', Icons.square_outlined),
    ('Қаймақ домашний', 'Қаймақ', '800 ₸ / кг', Icons.blur_circular_outlined),
    ('Шұбат натуральный', 'Шұбат', '900 ₸ / л', Icons.wine_bar_outlined),
    ('Молоко козье', 'Молоко', '550 ₸ / л', Icons.water_drop_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final (name, category, price, icon) =
        _mockProducts[index % _mockProducts.length];
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(category,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(price,
                      style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: onTap,
                    style: FilledButton.styleFrom(
                        minimumSize: const Size(72, 32),
                        padding: EdgeInsets.zero),
                    child: const Text('Открыть'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
