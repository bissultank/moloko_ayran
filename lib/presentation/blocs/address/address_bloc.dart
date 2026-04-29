// Слой: presentation | Назначение: AddressBloc

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/address.dart';
import '../../../domain/usecases/address_usecases.dart';

part 'address_event.dart';
part 'address_state.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  AddressBloc({
    required GetUserAddressesUseCase getUserAddressesUseCase,
    required CreateAddressUseCase createUseCase,
    required UpdateAddressUseCase updateUseCase,
    required DeleteAddressUseCase deleteUseCase,
    required SetDefaultAddressUseCase setDefaultUseCase,
  })  : _getUserAddressesUseCase = getUserAddressesUseCase,
        _createUseCase = createUseCase,
        _updateUseCase = updateUseCase,
        _deleteUseCase = deleteUseCase,
        _setDefaultUseCase = setDefaultUseCase,
        super(const AddressInitial()) {
    on<AddressLoad>(_onLoad);
    on<AddressCreate>(_onCreate);
    on<AddressUpdate>(_onUpdate);
    on<AddressDelete>(_onDelete);
    on<AddressSetDefault>(_onSetDefault);
  }

  final GetUserAddressesUseCase _getUserAddressesUseCase;
  final CreateAddressUseCase _createUseCase;
  final UpdateAddressUseCase _updateUseCase;
  final DeleteAddressUseCase _deleteUseCase;
  final SetDefaultAddressUseCase _setDefaultUseCase;

  int? _currentUserId;

  Future<void> _onLoad(AddressLoad event, Emitter<AddressState> emit) async {
    _currentUserId = event.userId;
    emit(const AddressLoading());
    try {
      final addresses = await _getUserAddressesUseCase(event.userId);
      emit(AddressLoaded(addresses));
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  Future<void> _onCreate(
      AddressCreate event, Emitter<AddressState> emit) async {
    try {
      await _createUseCase(event.address);
      if (_currentUserId != null) add(AddressLoad(_currentUserId!));
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  Future<void> _onUpdate(
      AddressUpdate event, Emitter<AddressState> emit) async {
    try {
      await _updateUseCase(event.address);
      if (_currentUserId != null) add(AddressLoad(_currentUserId!));
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  Future<void> _onDelete(
      AddressDelete event, Emitter<AddressState> emit) async {
    try {
      await _deleteUseCase(event.id);
      if (_currentUserId != null) add(AddressLoad(_currentUserId!));
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  Future<void> _onSetDefault(
      AddressSetDefault event, Emitter<AddressState> emit) async {
    try {
      await _setDefaultUseCase(event.userId, event.addressId);
      add(AddressLoad(event.userId));
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }
}
