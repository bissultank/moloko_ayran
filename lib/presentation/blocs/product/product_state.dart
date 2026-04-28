part of 'product_bloc.dart';

abstract class ProductState extends Equatable {
  const ProductState();
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

class ProductLoaded extends ProductState {
  const ProductLoaded(this.products, {this.selectedCategory, this.searchQuery});
  final List<Product> products;
  final ProductCategory? selectedCategory;
  final String? searchQuery;
  @override
  List<Object?> get props => [products, selectedCategory, searchQuery];
}

class ProductError extends ProductState {
  const ProductError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
