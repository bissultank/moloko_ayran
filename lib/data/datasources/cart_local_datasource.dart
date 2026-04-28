// Слой: data | Назначение: локальный datasource для корзины

import 'package:drift/drift.dart';

import '../../domain/entities/product.dart';
import '../../presentation/blocs/cart/cart_line.dart';
import 'app_database.dart';

class CartLocalDatasource {
  CartLocalDatasource(this._db);

  final AppDatabase _db;

  Future<List<CartLine>> getByUserId(int userId) async {
    final rows = await (_db.select(_db.cartItems)
          ..where((c) => c.userId.equals(userId)))
        .get();
    return rows.map(_toCartLine).toList();
  }

  Future<void> addOrIncrement(int userId, Product product, int quantity) async {
    final existing = await (_db.select(_db.cartItems)
          ..where(
              (c) => c.userId.equals(userId) & c.productId.equals(product.id)))
        .getSingleOrNull();

    if (existing != null) {
      await (_db.update(_db.cartItems)..where((c) => c.id.equals(existing.id)))
          .write(CartItemsCompanion(
              quantity: Value(existing.quantity + quantity)));
    } else {
      await _db.into(_db.cartItems).insert(
            CartItemsCompanion.insert(
              userId: userId,
              productId: product.id,
              quantity: quantity,
              productName: product.name,
              category: product.category.name,
              price: product.price,
              unit: product.unit,
              farmer: product.farmer,
            ),
          );
    }
  }

  Future<void> setQuantity(int userId, int productId, int quantity) async {
    if (quantity <= 0) {
      await removeByProduct(userId, productId);
      return;
    }
    await (_db.update(_db.cartItems)
          ..where(
              (c) => c.userId.equals(userId) & c.productId.equals(productId)))
        .write(CartItemsCompanion(quantity: Value(quantity)));
  }

  Future<void> removeByProduct(int userId, int productId) async {
    await (_db.delete(_db.cartItems)
          ..where(
              (c) => c.userId.equals(userId) & c.productId.equals(productId)))
        .go();
  }

  Future<void> clearByUser(int userId) async {
    await (_db.delete(_db.cartItems)..where((c) => c.userId.equals(userId)))
        .go();
  }

  CartLine _toCartLine(CartItemRow row) => CartLine(
        product: Product(
          id: row.productId,
          name: row.productName,
          category: ProductCategory.fromString(row.category),
          price: row.price,
          unit: row.unit,
          farmer: row.farmer,
          description: '',
          isAvailable: true,
        ),
        quantity: row.quantity,
      );
}
