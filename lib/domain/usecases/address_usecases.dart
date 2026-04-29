// Слой: domain | Назначение: use cases для адресов

import '../entities/address.dart';
import '../repositories/address_repository.dart';

class GetUserAddressesUseCase {
  GetUserAddressesUseCase(this._repository);
  final AddressRepository _repository;
  Future<List<Address>> call(int userId) => _repository.getByUserId(userId);
}

class CreateAddressUseCase {
  CreateAddressUseCase(this._repository);
  final AddressRepository _repository;
  Future<int> call(Address address) => _repository.create(address);
}

class UpdateAddressUseCase {
  UpdateAddressUseCase(this._repository);
  final AddressRepository _repository;
  Future<void> call(Address address) => _repository.update(address);
}

class DeleteAddressUseCase {
  DeleteAddressUseCase(this._repository);
  final AddressRepository _repository;
  Future<void> call(int id) => _repository.delete(id);
}

class SetDefaultAddressUseCase {
  SetDefaultAddressUseCase(this._repository);
  final AddressRepository _repository;
  Future<void> call(int userId, int addressId) =>
      _repository.setDefault(userId, addressId);
}
