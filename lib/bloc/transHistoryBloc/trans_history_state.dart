part of 'trans_history_bloc.dart';

sealed class TransHistoryState extends Equatable {
  const TransHistoryState();
  
  @override
  List<Object> get props => [];
}

class TransHistoryInitial extends TransHistoryState {}

class TransHistoryLoading extends TransHistoryState {}

class TransHistoryLoaded extends TransHistoryState {
  final List<Map<String, dynamic>> transactions;
  final bool hasMoreData;
  final int currentPage;

  const TransHistoryLoaded({
    required this.transactions,
    required this.hasMoreData,
    required this.currentPage,
  });

  @override
  List<Object> get props => [transactions, hasMoreData, currentPage];
}

class TransHistoryError extends TransHistoryState {
  final String message;

  const TransHistoryError(this.message);

  @override
  List<Object> get props => [message];
}
