part of 'updatewallet_bloc_bloc.dart';

abstract class UpdatewalletBlocEvent extends Equatable {
  const UpdatewalletBlocEvent();

  @override
  List<Object> get props => [];
}

class UpdateWalletAddressEvent extends UpdatewalletBlocEvent {
  final String newAddress;

  const UpdateWalletAddressEvent({required this.newAddress});

  @override
  List<Object> get props => [newAddress];
}
