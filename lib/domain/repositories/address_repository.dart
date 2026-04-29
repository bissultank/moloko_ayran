// Слой: domain | Назначение: интерфейс репозитория адресов

import '../entities/address.dart';

abstract class AddressRepository {
  Future<List<Address>> getByUserId(int userId);
  Future<Address?> getDefault(int userId);
  Future<int> create(Address address);
  Future<void> update(Address address);
  Future<void> delete(int id);
  Future<void> setDefault(int userId, int addressId);
}
