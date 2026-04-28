// Слой: data | Назначение: реализация ProductRepository

import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._datasource);

  final ProductLocalDatasource _datasource;

  @override
  Future<List<Product>> getAll() => _datasource.getAll();

  @override
  Future<Product?> getById(int id) => _datasource.getById(id);

  @override
  Future<List<Product>> getByCategory(ProductCategory category) =>
      _datasource.getByCategory(category);

  @override
  Future<List<Product>> search(String query) => _datasource.search(query);

  @override
  Future<int> create(Product product) => _datasource.create(product);

  @override
  Future<void> update(Product product) => _datasource.update(product);

  @override
  Future<void> delete(int id) => _datasource.delete(id);
}
