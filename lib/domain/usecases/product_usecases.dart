// Слой: domain | Назначение: use cases для продуктов

import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetAllProductsUseCase {
  GetAllProductsUseCase(this._repository);
  final ProductRepository _repository;
  Future<List<Product>> call() => _repository.getAll();
}

class GetProductByIdUseCase {
  GetProductByIdUseCase(this._repository);
  final ProductRepository _repository;
  Future<Product?> call(int id) => _repository.getById(id);
}

class GetProductsByCategoryUseCase {
  GetProductsByCategoryUseCase(this._repository);
  final ProductRepository _repository;
  Future<List<Product>> call(ProductCategory category) =>
      _repository.getByCategory(category);
}

class SearchProductsUseCase {
  SearchProductsUseCase(this._repository);
  final ProductRepository _repository;
  Future<List<Product>> call(String query) => _repository.search(query);
}

class CreateProductUseCase {
  CreateProductUseCase(this._repository);
  final ProductRepository _repository;
  Future<int> call(Product product) => _repository.create(product);
}

class UpdateProductUseCase {
  UpdateProductUseCase(this._repository);
  final ProductRepository _repository;
  Future<void> call(Product product) => _repository.update(product);
}

class DeleteProductUseCase {
  DeleteProductUseCase(this._repository);
  final ProductRepository _repository;
  Future<void> call(int id) => _repository.delete(id);
}
