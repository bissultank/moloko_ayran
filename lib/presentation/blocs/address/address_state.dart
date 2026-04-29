part of 'address_bloc.dart';

abstract class AddressState extends Equatable {
  const AddressState();
  @override
  List<Object?> get props => [];
}

class AddressInitial extends AddressState {
  const AddressInitial();
}

class AddressLoading extends AddressState {
  const AddressLoading();
}

class AddressLoaded extends AddressState {
  const AddressLoaded(this.addresses);
  final List<Address> addresses;
  Address? get defaultAddress {
    for (final a in addresses) {
      if (a.isDefault) return a;
    }
    return addresses.isNotEmpty ? addresses.first : null;
  }

  @override
  List<Object?> get props => [addresses];
}

class AddressError extends AddressState {
  const AddressError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
