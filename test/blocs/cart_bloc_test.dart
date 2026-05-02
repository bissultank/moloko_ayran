import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moloko_ayran/data/datasources/cart_local_datasource.dart';
import 'package:moloko_ayran/domain/entities/product.dart';
import 'package:moloko_ayran/presentation/blocs/cart/cart_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockCartDatasource extends Mock implements CartLocalDatasource {}

void main() {
  late MockCartDatasource mockDatasource;

  // Тестовый продукт
  const testProduct = Product(
    id: 1,
    name: 'Молоко 3.2%',
    category: ProductCategory.milk,
    price: 450,
    unit: 'л',
    farmer: 'Ферма Тест',
    description: '',
    isAvailable: true,
  );

  const testProduct2 = Product(
    id: 2,
    name: 'Айран',
    category: ProductCategory.ayran,
    price: 350,
    unit: 'л',
    farmer: 'Ферма Тест',
    description: '',
    isAvailable: true,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({'session_user_id': 1});
    mockDatasource = MockCartDatasource();

    registerFallbackValue(testProduct);
  });

  group('CartBloc', () {
    test('начальное состояние — пустая корзина', () {
      final bloc = CartBloc(mockDatasource);
      expect(bloc.state.items, isEmpty);
      expect(bloc.state.isEmpty, true);
      expect(bloc.state.totalItems, 0);
      expect(bloc.state.totalPrice, 0);
    });

    blocTest<CartBloc, CartState>(
      'CartLoad — загружает товары из datasource',
      setUp: () {
        when(() => mockDatasource.getByUserId(any())).thenAnswer((_) async => [
              const CartLine(product: testProduct, quantity: 2),
              const CartLine(product: testProduct2, quantity: 1),
            ]);
      },
      build: () => CartBloc(mockDatasource),
      act: (bloc) => bloc.add(const CartLoad()),
      verify: (bloc) {
        expect(bloc.state.items.length, 2);
        expect(bloc.state.totalItems, 3);
        expect(bloc.state.totalPrice, 450 * 2 + 350);
      },
    );

    blocTest<CartBloc, CartState>(
      'CartAdd — добавляет товар через datasource',
      setUp: () {
        when(() => mockDatasource.addOrIncrement(any(), any(), any()))
            .thenAnswer((_) async {});
        when(() => mockDatasource.getByUserId(any())).thenAnswer((_) async => [
              const CartLine(product: testProduct, quantity: 1),
            ]);
      },
      build: () => CartBloc(mockDatasource),
      act: (bloc) => bloc.add(const CartAdd(testProduct)),
      verify: (bloc) {
        verify(() => mockDatasource.addOrIncrement(1, testProduct, 1))
            .called(1);
        expect(bloc.state.items.length, 1);
      },
    );

    blocTest<CartBloc, CartState>(
      'CartRemove — удаляет товар',
      setUp: () {
        when(() => mockDatasource.removeByProduct(any(), any()))
            .thenAnswer((_) async {});
        when(() => mockDatasource.getByUserId(any()))
            .thenAnswer((_) async => []);
      },
      build: () => CartBloc(mockDatasource),
      act: (bloc) => bloc.add(const CartRemove(1)),
      verify: (bloc) {
        verify(() => mockDatasource.removeByProduct(1, 1)).called(1);
        expect(bloc.state.isEmpty, true);
      },
    );

    blocTest<CartBloc, CartState>(
      'CartClear — очищает корзину',
      setUp: () {
        when(() => mockDatasource.clearByUser(any())).thenAnswer((_) async {});
      },
      build: () => CartBloc(mockDatasource),
      seed: () => const CartState(items: {
        1: CartLine(product: testProduct, quantity: 3),
      }),
      act: (bloc) => bloc.add(const CartClear()),
      expect: () => [
        const CartState(items: {}),
      ],
      verify: (_) {
        verify(() => mockDatasource.clearByUser(1)).called(1);
      },
    );

    test('CartState.totalItems — корректно суммирует количество', () {
      const state = CartState(items: {
        1: CartLine(product: testProduct, quantity: 2),
        2: CartLine(product: testProduct2, quantity: 3),
      });
      expect(state.totalItems, 5);
    });

    test('CartState.totalPrice — корректно считает сумму', () {
      const state = CartState(items: {
        1: CartLine(product: testProduct, quantity: 2),
        2: CartLine(product: testProduct2, quantity: 1),
      });
      expect(state.totalPrice, 450 * 2 + 350);
    });

    test('CartLine.total — цена × количество', () {
      const line = CartLine(product: testProduct, quantity: 3);
      expect(line.total, 1350);
    });
  });
}
