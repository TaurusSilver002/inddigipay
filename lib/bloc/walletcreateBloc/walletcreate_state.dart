part of 'walletcreate_bloc.dart';

sealed class WalletcreateState extends Equatable {
  const WalletcreateState();
  
  @override
  List<Object> get props => [];
}

final class WalletcreateInitial extends WalletcreateState {}
