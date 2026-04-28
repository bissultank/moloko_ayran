// Слой: presentation | Назначение: ProductBloc — управление состоянием продуктов

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/product.dart';
import '../../../domain/usecases/product_usecases.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc({
    required GetAllProductsUseCase getAllUseCase,
    required SearchProductsUseCase searchUseCase,
    required GetProductsByCategoryUseCase getByCategoryUseCase,
    required CreateProductUseCase createUseCase,
    required UpdateProductUseCase updateUseCase,
    required DeleteProductUseCase deleteUseCase,
  })  : _getAllUseCase = getAllUseCase,
        _searchUseCase = searchUseCase,
        _getByCategoryUseCase = getByCategoryUseCase,
        _createUseCase = createUseCase,
        _updateUseCase = updateUseCase,
        _deleteUseCase = deleteUseCase,
        super(const ProductInitial()) {
    on<ProductLoadAll>(_onLoadAll);
    on<ProductFilterByCategory>(_onFilterByCategory);
    on<ProductSearch>(_onSearch);
    on<ProductCreate>(_onCreate);
    on<ProductUpdate>(_onUpdate);
    on<ProductDelete>(_onDelete);
  }

  final GetAllProductsUseCase _getAllUseCase;
  final SearchProductsUseCase _searchUseCase;
  final GetProductsByCategoryUseCase _getByCategoryUseCase;
  final CreateProductUseCase _createUseCase;
  final UpdateProductUseCase _updateUseCase;
  final DeleteProductUseCase _deleteUseCase;

  Future<void> _onLoadAll(
      ProductLoadAll event, Emitter<ProductState> emit) async {
    emit(const ProductLoading());
    try {
      final products = await _getAllUseCase();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onFilterByCategory(
      ProductFilterByCategory event, Emitter<ProductState> emit) async {
    emit(const ProductLoading());
    try {
      final products = event.category == null
          ? await _getAllUseCase()
          : await _getByCategoryUseCase(event.category!);
      emit(ProductLoaded(products, selectedCategory: event.category));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onSearch(
      ProductSearch event, Emitter<ProductState> emit) async {
    try {
      final products = event.query.trim().isEmpty
          ? await _getAllUseCase()
          : await _searchUseCase(event.query);
      emit(ProductLoaded(products, searchQuery: event.query));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onCreate(
      ProductCreate event, Emitter<ProductState> emit) async {
    try {
      await _createUseCase(event.product);
      add(const ProductLoadAll());
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onUpdate(
      ProductUpdate event, Emitter<ProductState> emit) async {
    try {
      await _updateUseCase(event.product);
      add(const ProductLoadAll());
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onDelete(
      ProductDelete event, Emitter<ProductState> emit) async {
    try {
      await _deleteUseCase(event.id);
      add(const ProductLoadAll());
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}
