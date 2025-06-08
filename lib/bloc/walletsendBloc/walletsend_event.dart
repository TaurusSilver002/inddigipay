part of 'walletsend_bloc.dart';

abstract class WalletsendEvent extends Equatable {
  const WalletsendEvent();

  @override
  List<Object> get props => [];
}

class SendTransactionEvent extends WalletsendEvent {
  final String passPhrase;
  final String to;
  final double amount;

  const SendTransactionEvent({
    required this.passPhrase,
    required this.to,
    required this.amount,
  });

  @override
  List<Object> get props => [passPhrase, to, amount];
}
