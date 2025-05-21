import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:inddigipay/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final Dio _dio = Dio();
  int _depositCount = 0; // Variable to store the count of deposit transactions

  TransactionBloc() : super(TransactionInitialState()) {
    on<FetchTransactionEvent>(_onFetchTransaction);
    on<FetchTransactionEventWithDate>(_onFetchTransactionWithDate);
  }

  Future<void> _onFetchTransaction(
      FetchTransactionEvent event, Emitter<TransactionState> emit) async {
    emit(TransactionLoadingState());

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token == null) {
        emit(TransactionFailureState(message: 'User not authenticated.'));
        return;
      }

      final response = await _dio.post(
        AppConfig.transaction,
        data: {
          'page': event.page,
          'limit': event.limit,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data is List) {
        List<Map<String, dynamic>> transactions = (response.data as List)
            .map((item) => item as Map<String, dynamic>)
            .toList();

        // Count transactions with `transaction_type` == 0 as deposits
        _depositCount = transactions
            .where((transaction) => transaction['transaction_type'] == 0)
            .length;

        // Log the count (optional)
        print('Number of deposit transactions: $_depositCount');

        emit(TransactionSuccessState(transactions: transactions));
      } else {
        emit(TransactionFailureState(message: 'Failed to load transactions.'));
      }
    } catch (e) {
      emit(TransactionFailureState(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onFetchTransactionWithDate(
      FetchTransactionEventWithDate event, Emitter<TransactionState> emit) async {
    emit(TransactionLoadingState());

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token == null) {
        emit(TransactionFailureState(message: 'User not authenticated.'));
        return;
      }

      final response = await _dio.post(
        AppConfig.transaction,
        data: {
          'page': event.page,
          'limit': event.limit,
          'from_date': event.startDate.toIso8601String(),
          'to_date': event.endDate.toIso8601String(),
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data is List) {
        List<Map<String, dynamic>> transactions = (response.data as List)
            .map((item) => item as Map<String, dynamic>)
            .toList();

        // Count transactions with `transaction_type` == 0 as deposits
        _depositCount = transactions
            .where((transaction) => transaction['transaction_type'] == 0)
            .length;

        // Log the count (optional)
        print('Number of deposit transactions: $_depositCount');

        emit(TransactionSuccessState(transactions: transactions));
      } else {
        emit(TransactionFailureState(message: 'Failed to load transactions.'));
      }
    } catch (e) {
      emit(TransactionFailureState(message: 'An error occurred: ${e.toString()}'));
    }
  }

  // Getter to access the deposit count from outside the bloc
  int get depositCount => _depositCount;
}
