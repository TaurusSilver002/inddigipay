import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inddigipay/config.dart';

part 'trans_history_event.dart';
part 'trans_history_state.dart';

class TransHistoryBloc extends Bloc<TransHistoryEvent, TransHistoryState> {
  final Dio _dio = Dio();
  final List<Map<String, dynamic>> _allTransactions = [];

  TransHistoryBloc() : super(TransHistoryInitial()) {
    print('TransHistoryBloc created');
    on<FetchTransHistory>(_onFetchTransHistory);
    on<LoadMoreTransHistory>(_onLoadMoreTransHistory);
  }

Future<void> _onFetchTransHistory(
  FetchTransHistory event,
  Emitter<TransHistoryState> emit,
) async {
  try {
    print('_onFetchTransHistory called with event: $event');
    emit(TransHistoryLoading());

    print('Fetching transaction history for address: ${event.address}');
    final response = await _dio.get(
      '${AppConfig.transactionhistory}?address=${event.address}&page=${event.page}&offset=${event.offset}',
      options: Options(
        headers: {
          'accept': 'application/json',
        },
      ),
    );
    print('Got response with status: ${response.statusCode}');

    if (response.statusCode == 200) {
     final data = response.data;
if (data is Map<String, dynamic> && data['status'] == '1' && data['result'] is List) {
  final transactions = List<Map<String, dynamic>>.from(data['result']);
  _allTransactions.clear();
  _allTransactions.addAll(transactions);

  emit(TransHistoryLoaded(
    transactions: transactions,
    hasMoreData: transactions.length >= event.offset,
    currentPage: event.page,
  ));
} else {
  emit(const TransHistoryError('Invalid response format'));
}

    } else {
      emit(TransHistoryError('Failed to load transactions: ${response.statusMessage}'));
    }
  } catch (e) {
    emit(TransHistoryError('An error occurred: ${e.toString()}'));
  }
}

  Future<void> _onLoadMoreTransHistory(
    LoadMoreTransHistory event,
    Emitter<TransHistoryState> emit,
  ) async {
    try {
      // Keep current transactions visible while loading more
      final currentState = state;
      if (currentState is TransHistoryLoaded) {
        

       

        final nextPage = event.currentPage + 1;
        
        final response = await _dio.get(
          '${AppConfig.transactionhistory}?address=${event.address}&page=$nextPage&offset=${event.offset}',
          options: Options(
            headers: {
              'accept': 'application/json',
            },
          ),
        );

        if (response.statusCode == 200) {
          final data = response.data;
          if (data is Map<String, dynamic> && data['status'] == '1' && data['result'] is List) {
            final newTransactions = List<Map<String, dynamic>>.from(data['result']);
            _allTransactions.addAll(newTransactions);

            emit(TransHistoryLoaded(
              transactions: _allTransactions,
              hasMoreData: newTransactions.length >= event.offset,
              currentPage: nextPage,
            ));
          } else {
            emit(const TransHistoryError('Invalid response format'));
          }
        } else {
          emit(TransHistoryError('Failed to load more transactions: ${response.statusMessage}'));
        }
      }
    } catch (e) {
      emit(TransHistoryError('An error occurred while loading more: ${e.toString()}'));
    }
  }
}
