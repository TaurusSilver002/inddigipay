part of 'check_bloc.dart';

abstract class CheckEvent extends Equatable {
  const CheckEvent();

  @override
  List<Object> get props => [];
}

class CheckStatusEvent extends CheckEvent {
  final int transactionId;

  const CheckStatusEvent({required this.transactionId});

  @override
  List<Object> get props => [transactionId];
}


