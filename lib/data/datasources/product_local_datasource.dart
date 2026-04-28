// Слой: data | Назначение: локальный datasource для продуктов (Drift)

import 'package:drift/drift.dart';

import '../../domain/entities/product.dart';
import 'app_database.dart';

class ProductLocalDatasource {
  ProductLocalDatasource(this._db);

  final AppDatabase _db;

  Future<List<Product>> getAll() async {
    final rows = await _db.select(_db.products).get();
    return rows.map(_toEntity).toList();
  }

  Future<Product?> getById(int id) async {
    final row = await (_db.select(_db.products)..where((p) => p.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  Future<List<Product>> getByCategory(ProductCategory category) async {
    final rows = await (_db.select(_db.products)
          ..where((p) => p.category.equals(category.name)))
        .get();
    return rows.map(_toEntity).toList();
  }

  Future<List<Product>> search(String query) async {
    final lower = '%${query.toLowerCase()}%';
    final rows = await (_db.select(_db.products)
          ..where((p) => p.name.lower().like(lower)))
        .get();
    return rows.map(_toEntity).toList();
  }

  Future<int> create(Product product) async {
    return _db.into(_db.products).insert(
          ProductsCompanion.insert(
            name: product.name,
            category: product.category.name,
            price: product.price,
            unit: product.unit,
            farmer: product.farmer,
            description: Value(product.description),
            isAvailable: Value(product.isAvailable),
          ),
        );
  }

  Future<void> update(Product product) async {
    await (_db.update(_db.products)..where((p) => p.id.equals(product.id)))
        .write(
      ProductsCompanion(
        name: Value(product.name),
        category: Value(product.category.name),
        price: Value(product.price),
        unit: Value(product.unit),
        farmer: Value(product.farmer),
        description: Value(product.description),
        isAvailable: Value(product.isAvailable),
      ),
    );
  }

  Future<void> delete(int id) async {
    await (_db.delete(_db.products)..where((p) => p.id.equals(id))).go();
  }

  // Сидинг — добавить продукты только если БД пустая
  Future<void> seedIfEmpty() async {
    final count = await (_db.selectOnly(_db.products)
          ..addColumns([_db.products.id.count()]))
        .map((row) => row.read(_db.products.id.count())!)
        .getSingle();
    if (count > 0) return;

    final initial = <ProductsCompanion>[
      ProductsCompanion.insert(
          name: 'Молоко коровье 3.2%',
          category: ProductCategory.milk.name,
          price: 450,
          unit: 'л',
          farmer: 'Ферма Табиғат'),
      ProductsCompanion.insert(
          name: 'Молоко козье',
          category: ProductCategory.milk.name,
          price: 750,
          unit: 'л',
          farmer: 'Ферма Алатау'),
      ProductsCompanion.insert(
          name: 'Айран классический',
          category: ProductCategory.ayran.name,
          price: 350,
          unit: 'л',
          farmer: 'Ферма Табиғат'),
      ProductsCompanion.insert(
          name: 'Кефир 1%',
          category: ProductCategory.kefir.name,
          price: 380,
          unit: 'л',
          farmer: 'Ферма Алатау'),
      ProductsCompanion.insert(
          name: 'Кефир 3.2%',
          category: ProductCategory.kefir.name,
          price: 420,
          unit: 'л',
          farmer: 'Ферма Алатау'),
      ProductsCompanion.insert(
          name: 'Сметана 20%',
          category: ProductCategory.smetana.name,
          price: 600,
          unit: 'кг',
          farmer: 'Ферма Жайлау'),
      ProductsCompanion.insert(
          name: 'Сметана 25%',
          category: ProductCategory.smetana.name,
          price: 700,
          unit: 'кг',
          farmer: 'Ферма Жайлау'),
      ProductsCompanion.insert(
          name: 'Творог зернистый',
          category: ProductCategory.tvorog.name,
          price: 800,
          unit: 'кг',
          farmer: 'Ферма Табиғат'),
      ProductsCompanion.insert(
          name: 'Творог 9%',
          category: ProductCategory.tvorog.name,
          price: 750,
          unit: 'кг',
          farmer: 'Ферма Жайлау'),
      ProductsCompanion.insert(
          name: 'Масло сливочное 82%',
          category: ProductCategory.butter.name,
          price: 1800,
          unit: 'кг',
          farmer: 'Ферма Табиғат'),
      ProductsCompanion.insert(
          name: 'Сыр адыгейский',
          category: ProductCategory.cheese.name,
          price: 2200,
          unit: 'кг',
          farmer: 'Ферма Алатау'),
      ProductsCompanion.insert(
          name: 'Йогурт натуральный',
          category: ProductCategory.yogurt.name,
          price: 480,
          unit: 'л',
          farmer: 'Ферма Жайлау'),
      ProductsCompanion.insert(
          name: 'Құрт солёный',
          category: ProductCategory.other.name,
          price: 1200,
          unit: 'кг',
          farmer: 'Ферма Алатау'),
      ProductsCompanion.insert(
          name: 'Қаймақ домашний',
          category: ProductCategory.other.name,
          price: 950,
          unit: 'кг',
          farmer: 'Ферма Жайлау'),
    ];

    await _db.batch((b) => b.insertAll(_db.products, initial));
  }

  Product _toEntity(ProductRow row) => Product(
        id: row.id,
        name: row.name,
        category: ProductCategory.fromString(row.category),
        price: row.price,
        unit: row.unit,
        farmer: row.farmer,
        description: row.description,
        isAvailable: row.isAvailable,
      );
}
