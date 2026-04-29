part of 'address_bloc.dart';

abstract class AddressEvent extends Equatable {
  const AddressEvent();
  @override
  List<Object?> get props => [];
}

class AddressLoad extends AddressEvent {
  const AddressLoad(this.userId);
  final int userId;
  @override
  List<Object?> get props => [userId];
}

class AddressCreate extends AddressEvent {
  const AddressCreate(this.address);
  final Address address;
  @override
  List<Object?> get props => [address];
}

class AddressUpdate extends AddressEvent {
  const AddressUpdate(this.address);
  final Address address;
  @override
  List<Object?> get props => [address];
}

class AddressDelete extends AddressEvent {
  const AddressDelete(this.id);
  final int id;
  @override
  List<Object?> get props => [id];
}

class AddressSetDefault extends AddressEvent {
  const AddressSetDefault(this.userId, this.addressId);
  final int userId;
  final int addressId;
  @override
  List<Object?> get props => [userId, addressId];
}
