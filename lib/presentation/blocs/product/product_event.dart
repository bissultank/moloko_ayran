part of 'product_bloc.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();
  @override
  List<Object?> get props => [];
}

class ProductLoadAll extends ProductEvent {
  const ProductLoadAll();
}

class ProductFilterByCategory extends ProductEvent {
  const ProductFilterByCategory(this.category);
  final ProductCategory? category; // null = все
  @override
  List<Object?> get props => [category];
}

class ProductSearch extends ProductEvent {
  const ProductSearch(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

class ProductCreate extends ProductEvent {
  const ProductCreate(this.product);
  final Product product;
  @override
  List<Object?> get props => [product];
}

class ProductUpdate extends ProductEvent {
  const ProductUpdate(this.product);
  final Product product;
  @override
  List<Object?> get props => [product];
}

class ProductDelete extends ProductEvent {
  const ProductDelete(this.id);
  final int id;
  @override
  List<Object?> get props => [id];
}
