import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moloko_ayran/domain/entities/order.dart';
import 'package:moloko_ayran/domain/usecases/order_usecases.dart';
import 'package:moloko_ayran/presentation/blocs/order/order_bloc.dart';

class MockGetUserOrdersUseCase extends Mock implements GetUserOrdersUseCase {}

class MockGetOrdersByStatusUseCase extends Mock
    implements GetOrdersByStatusUseCase {}

class MockCreateOrderUseCase extends Mock implements CreateOrderUseCase {}

class MockUpdateOrderStatusUseCase extends Mock
    implements UpdateOrderStatusUseCase {}

class MockDeleteOrderUseCase extends Mock implements DeleteOrderUseCase {}

void main() {
  late MockGetUserOrdersUseCase getUserOrders;
  late MockGetOrdersByStatusUseCase getByStatus;
  late MockCreateOrderUseCase createUseCase;
  late MockUpdateOrderStatusUseCase updateStatusUseCase;
  late MockDeleteOrderUseCase deleteUseCase;

  final testOrder = OrderEntity(
    id: 1,
    userId: 1,
    items: const [
      OrderItem(
        productId: 1,
        productName: 'Молоко 3.2%',
        category: 'milk',
        price: 450,
        unit: 'л',
        quantity: 2,
      ),
    ],
    totalPrice: 900,
    status: OrderStatus.pending,
    createdAt: DateTime(2026, 1, 1),
  );

  final testOrder2 = testOrder.copyWith(id: 2, status: OrderStatus.delivered);

  setUp(() {
    getUserOrders = MockGetUserOrdersUseCase();
    getByStatus = MockGetOrdersByStatusUseCase();
    createUseCase = MockCreateOrderUseCase();
    updateStatusUseCase = MockUpdateOrderStatusUseCase();
    deleteUseCase = MockDeleteOrderUseCase();

    registerFallbackValue(testOrder);
    registerFallbackValue(OrderStatus.pending);
  });

  OrderBloc buildBloc() => OrderBloc(
        getUserOrdersUseCase: getUserOrders,
        getByStatusUseCase: getByStatus,
        createUseCase: createUseCase,
        updateStatusUseCase: updateStatusUseCase,
        deleteUseCase: deleteUseCase,
      );

  group('OrderBloc', () {
    test('начальное состояние — OrderInitial', () {
      expect(buildBloc().state, isA<OrderInitial>());
    });

    blocTest<OrderBloc, OrderState>(
      'OrderLoadAll — загружает заказы',
      setUp: () {
        when(() => getUserOrders(any()))
            .thenAnswer((_) async => [testOrder, testOrder2]);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const OrderLoadAll(1)),
      expect: () => [
        isA<OrderLoading>(),
        isA<OrderLoaded>().having((s) => s.orders.length, 'orders.length', 2),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'OrderLoadAll при ошибке — OrderError',
      setUp: () {
        when(() => getUserOrders(any())).thenThrow(Exception('БД недоступна'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const OrderLoadAll(1)),
      expect: () => [
        isA<OrderLoading>(),
        isA<OrderError>(),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'OrderFilterByStatus — фильтрует по статусу',
      setUp: () {
        when(() => getUserOrders(any()))
            .thenAnswer((_) async => [testOrder, testOrder2]);
        when(() => getByStatus(any(), any()))
            .thenAnswer((_) async => [testOrder]);
      },
      build: buildBloc,
      act: (bloc) {
        bloc.add(const OrderLoadAll(1));
        bloc.add(const OrderFilterByStatus(OrderStatus.pending));
      },
      verify: (_) {
        verify(() => getByStatus(1, OrderStatus.pending)).called(1);
      },
    );

    blocTest<OrderBloc, OrderState>(
      'OrderCreate — создаёт заказ и перезагружает список',
      setUp: () {
        when(() => createUseCase(any())).thenAnswer((_) async => 1);
        when(() => getUserOrders(any())).thenAnswer((_) async => [testOrder]);
      },
      build: buildBloc,
      act: (bloc) {
        bloc.add(const OrderLoadAll(1));
        bloc.add(OrderCreate(testOrder));
      },
      verify: (_) {
        verify(() => createUseCase(testOrder)).called(1);
      },
    );

    blocTest<OrderBloc, OrderState>(
      'OrderUpdateStatus — меняет статус',
      setUp: () {
        when(() => updateStatusUseCase(any(), any())).thenAnswer((_) async {});
        when(() => getUserOrders(any())).thenAnswer((_) async => [testOrder]);
      },
      build: buildBloc,
      act: (bloc) {
        bloc.add(const OrderLoadAll(1));
        bloc.add(const OrderUpdateStatus(1, OrderStatus.cancelled));
      },
      verify: (_) {
        verify(() => updateStatusUseCase(1, OrderStatus.cancelled)).called(1);
      },
    );

    blocTest<OrderBloc, OrderState>(
      'OrderDelete — удаляет заказ',
      setUp: () {
        when(() => deleteUseCase(any())).thenAnswer((_) async {});
        when(() => getUserOrders(any())).thenAnswer((_) async => []);
      },
      build: buildBloc,
      act: (bloc) {
        bloc.add(const OrderLoadAll(1));
        bloc.add(const OrderDelete(1));
      },
      verify: (_) {
        verify(() => deleteUseCase(1)).called(1);
      },
    );
  });

  group('OrderEntity', () {
    test('copyWith — копирует с изменениями', () {
      final updated = testOrder.copyWith(status: OrderStatus.delivered);
      expect(updated.status, OrderStatus.delivered);
      expect(updated.id, testOrder.id);
      expect(updated.totalPrice, testOrder.totalPrice);
    });
  });

  group('OrderStatus', () {
    test('fromString — корректно парсит', () {
      expect(OrderStatus.fromString('pending'), OrderStatus.pending);
      expect(OrderStatus.fromString('delivered'), OrderStatus.delivered);
      expect(OrderStatus.fromString('cancelled'), OrderStatus.cancelled);
    });

    test('fromString — неизвестное значение → pending', () {
      expect(OrderStatus.fromString('unknown'), OrderStatus.pending);
    });
  });

  group('OrderItem', () {
    const item = OrderItem(
      productId: 1,
      productName: 'Тест',
      category: 'milk',
      price: 100,
      unit: 'л',
      quantity: 3,
    );

    test('total — цена × количество', () {
      expect(item.total, 300);
    });

    test('toJson и fromJson — round trip', () {
      final json = item.toJson();
      final restored = OrderItem.fromJson(json);
      expect(restored, item);
    });
  });
}
