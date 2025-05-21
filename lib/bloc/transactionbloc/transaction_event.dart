part of 'transaction_bloc.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class FetchTransactionEvent extends TransactionEvent {
  final int page;
  final int limit;

  const FetchTransactionEvent({required this.page, required this.limit});

  @override
  List<Object?> get props => [page, limit];
}

class FetchTransactionEventWithDate extends TransactionEvent {
  final int page;
  final int limit;
  final DateTime startDate;
  final DateTime endDate;

  const FetchTransactionEventWithDate({
    required this.page,
    required this.limit,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [page, limit, startDate, endDate];
}
