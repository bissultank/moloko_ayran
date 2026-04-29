// Слой: data | Назначение: реализация AddressRepository

import '../../domain/entities/address.dart';
import '../../domain/repositories/address_repository.dart';
import '../datasources/address_local_datasource.dart';

class AddressRepositoryImpl implements AddressRepository {
  AddressRepositoryImpl(this._datasource);

  final AddressLocalDatasource _datasource;

  @override
  Future<List<Address>> getByUserId(int userId) =>
      _datasource.getByUserId(userId);

  @override
  Future<Address?> getDefault(int userId) => _datasource.getDefault(userId);

  @override
  Future<int> create(Address address) => _datasource.create(address);

  @override
  Future<void> update(Address address) => _datasource.update(address);

  @override
  Future<void> delete(int id) => _datasource.delete(id);

  @override
  Future<void> setDefault(int userId, int addressId) =>
      _datasource.setDefault(userId, addressId);
}
