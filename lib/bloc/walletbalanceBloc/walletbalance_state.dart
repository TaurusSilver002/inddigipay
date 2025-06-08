part of 'walletbalance_bloc.dart';

abstract class WalletbalanceState extends Equatable {
  const WalletbalanceState();
  
  @override
  List<Object> get props => [];
}

class WalletbalanceInitial extends WalletbalanceState {}

class WalletbalanceLoading extends WalletbalanceState {}

class WalletbalanceLoaded extends WalletbalanceState {
  final double balance;

  const WalletbalanceLoaded({required this.balance});

  @override
  List<Object> get props => [balance];
}

class WalletbalanceError extends WalletbalanceState {
  final String message;

  const WalletbalanceError({required this.message});

  @override
  List<Object> get props => [message];
}
