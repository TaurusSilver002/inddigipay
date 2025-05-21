part of 'withdraw_bloc.dart';

sealed class WithdrawEvent extends Equatable {
  const WithdrawEvent();

  @override
  List<Object> get props => [];
}

class WithdrawRequestEvent extends WithdrawEvent {
  final int amount; 

  const WithdrawRequestEvent({required this.amount});

  @override
  List<Object> get props => [amount];
}
