// Слой: data | Назначение: локальный datasource для адресов

import 'package:drift/drift.dart';

import '../../domain/entities/address.dart';
import 'app_database.dart';

class AddressLocalDatasource {
  AddressLocalDatasource(this._db);

  final AppDatabase _db;

  Future<List<Address>> getByUserId(int userId) async {
    final rows = await (_db.select(_db.addresses)
          ..where((a) => a.userId.equals(userId))
          ..orderBy([(a) => OrderingTerm.desc(a.isDefault)]))
        .get();
    return rows.map(_toEntity).toList();
  }

  Future<Address?> getDefault(int userId) async {
    final row = await (_db.select(_db.addresses)
          ..where((a) => a.userId.equals(userId) & a.isDefault.equals(true)))
        .getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  Future<int> create(Address address) async {
    return _db.into(_db.addresses).insert(
          AddressesCompanion.insert(
            userId: address.userId,
            label: address.label,
            street: address.street,
            apartment: Value(address.apartment),
            city: address.city,
            isDefault: Value(address.isDefault),
          ),
        );
  }

  Future<void> update(Address address) async {
    await (_db.update(_db.addresses)..where((a) => a.id.equals(address.id)))
        .write(
      AddressesCompanion(
        label: Value(address.label),
        street: Value(address.street),
        apartment: Value(address.apartment),
        city: Value(address.city),
        isDefault: Value(address.isDefault),
      ),
    );
  }

  Future<void> delete(int id) async {
    await (_db.delete(_db.addresses)..where((a) => a.id.equals(id))).go();
  }

  Future<void> setDefault(int userId, int addressId) async {
    // Сбросить все default'ы
    await (_db.update(_db.addresses)..where((a) => a.userId.equals(userId)))
        .write(const AddressesCompanion(isDefault: Value(false)));
    // Установить новый default
    await (_db.update(_db.addresses)..where((a) => a.id.equals(addressId)))
        .write(const AddressesCompanion(isDefault: Value(true)));
  }

  Address _toEntity(AddressRow row) => Address(
        id: row.id,
        userId: row.userId,
        label: row.label,
        street: row.street,
        apartment: row.apartment,
        city: row.city,
        isDefault: row.isDefault,
      );
}
