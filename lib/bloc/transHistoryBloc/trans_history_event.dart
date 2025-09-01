part of 'trans_history_bloc.dart';

sealed class TransHistoryEvent extends Equatable {
  const TransHistoryEvent();

  @override
  List<Object> get props => [];
}

class FetchTransHistory extends TransHistoryEvent {
  final String address;
  final int page;
  final int offset;
  
  const FetchTransHistory({
    required this.address,
    required this.page,
    this.offset = 20,
  });

  @override
  List<Object> get props => [address, page, offset];
}

class LoadMoreTransHistory extends TransHistoryEvent {
  final String address;
  final int currentPage;
  final int offset;

  const LoadMoreTransHistory({
    required this.address,
    required this.currentPage,
    this.offset = 20,
  });

  @override
  List<Object> get props => [address, currentPage, offset];
}
