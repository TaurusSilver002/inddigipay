part of 'deposit_bloc.dart';

abstract class DepositEvent extends Equatable {
  const DepositEvent();

  @override
  List<Object> get props => [];
}

class DepositRequestEvent extends DepositEvent {
  final int amount;

  const DepositRequestEvent({required this.amount});

  @override
  List<Object> get props => [amount];
}
