// Слой: domain | Назначение: интерфейс репозитория продуктов

import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getAll();
  Future<Product?> getById(int id);
  Future<List<Product>> getByCategory(ProductCategory category);
  Future<List<Product>> search(String query);
  Future<int> create(Product product);
  Future<void> update(Product product);
  Future<void> delete(int id);
}
