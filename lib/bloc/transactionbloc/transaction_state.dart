part of 'transaction_bloc.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitialState extends TransactionState {}

class TransactionLoadingState extends TransactionState {}

class TransactionSuccessState extends TransactionState {
  final List<Map<String, dynamic>> transactions;

  const TransactionSuccessState({required this.transactions});

  @override
  List<Object?> get props => [transactions];
}

class TransactionFailureState extends TransactionState {
  final String message;

  const TransactionFailureState({required this.message});

  @override
  List<Object?> get props => [message];
}
