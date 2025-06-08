part of 'walletbalance_bloc.dart';

abstract class WalletbalanceEvent extends Equatable {
  const WalletbalanceEvent();

  @override
  List<Object> get props => [];
}

class FetchBalanceEvent extends WalletbalanceEvent {
  final String address;

  const FetchBalanceEvent({required this.address});

  @override
  List<Object> get props => [address];
}
