import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moloko_ayran/domain/entities/order.dart';
import 'package:moloko_ayran/domain/repositories/order_repository.dart';
import 'package:moloko_ayran/domain/usecases/order_usecases.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  late MockOrderRepository repo;

  final testOrder = OrderEntity(
    id: 1,
    userId: 1,
    items: const [
      OrderItem(
        productId: 1,
        productName: 'Молоко',
        category: 'milk',
        price: 450,
        unit: 'л',
        quantity: 1,
      ),
    ],
    totalPrice: 450,
    status: OrderStatus.pending,
    createdAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    repo = MockOrderRepository();
    registerFallbackValue(testOrder);
    registerFallbackValue(OrderStatus.pending);
  });

  group('CreateOrderUseCase', () {
    test('вызывает repository.create и возвращает id', () async {
      when(() => repo.create(any())).thenAnswer((_) async => 42);

      final useCase = CreateOrderUseCase(repo);
      final id = await useCase(testOrder);

      expect(id, 42);
      verify(() => repo.create(testOrder)).called(1);
    });
  });

  group('GetUserOrdersUseCase', () {
    test('возвращает список заказов', () async {
      when(() => repo.getByUserId(1))
          .thenAnswer((_) async => [testOrder, testOrder]);

      final useCase = GetUserOrdersUseCase(repo);
      final orders = await useCase(1);

      expect(orders.length, 2);
      verify(() => repo.getByUserId(1)).called(1);
    });
  });

  group('UpdateOrderStatusUseCase', () {
    test('передаёт статус в repository', () async {
      when(() => repo.updateStatus(any(), any())).thenAnswer((_) async {});

      final useCase = UpdateOrderStatusUseCase(repo);
      await useCase(1, OrderStatus.delivered);

      verify(() => repo.updateStatus(1, OrderStatus.delivered)).called(1);
    });
  });

  group('DeleteOrderUseCase', () {
    test('удаляет заказ по id', () async {
      when(() => repo.delete(any())).thenAnswer((_) async {});

      final useCase = DeleteOrderUseCase(repo);
      await useCase(1);

      verify(() => repo.delete(1)).called(1);
    });
  });
}
