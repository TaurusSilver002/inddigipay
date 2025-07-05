part of 'updatewallet_bloc_bloc.dart';

abstract class UpdatewalletBlocState extends Equatable {
  const UpdatewalletBlocState();

  @override
  List<Object> get props => [];
}

class UpdatewalletInitial extends UpdatewalletBlocState {}

class UpdateWalletLoading extends UpdatewalletBlocState {}

class UpdateWalletSuccess extends UpdatewalletBlocState {
  final String message;

  const UpdateWalletSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class UpdateWalletFailure extends UpdatewalletBlocState {
  final String error;

  const UpdateWalletFailure({required this.error});

  @override
  List<Object> get props => [error];
}
