part of 'walletcreate_bloc.dart';

abstract class WalletcreateState extends Equatable {
  const WalletcreateState();
  
  @override
  List<Object> get props => [];
}

class WalletcreateInitial extends WalletcreateState {}

class WalletcreateLoading extends WalletcreateState {}

class WalletcreateLoaded extends WalletcreateState {
  final List<Map<String, dynamic>> data;

  const WalletcreateLoaded(this.data);

  @override
  List<Object> get props => [data];
}

class WalletcreateError extends WalletcreateState {
  final String message;

  const WalletcreateError(this.message);

  @override
  List<Object> get props => [message];
}
