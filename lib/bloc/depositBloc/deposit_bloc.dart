import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:inddigipay/config.dart';

import 'package:shared_preferences/shared_preferences.dart';

part 'deposit_event.dart';
part 'deposit_state.dart';

class DepositBloc extends Bloc<DepositEvent, DepositState> {
  final Dio _dio = Dio();

  DepositBloc() : super(DepositInitial()) {
    on<DepositRequestEvent>(_onDepositRequest);
  }

  Future<void> _onDepositRequest(
    DepositRequestEvent event,
    Emitter<DepositState> emit,
  ) async {
    emit(DepositLoading());

    try {
      // Retrieve the token from shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token == null) {
        emit(DepositFailure(error: 'User not authenticated.'));
        return;
      }

      final response = await _dio.post(
        AppConfig.deposit,
        data: {'amount': event.amount.toDouble()},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      // Check response status and emit the appropriate state
      if (response.statusCode == 200) {
        // Validate admin_wallet presence
        if (response.data['admin_wallet'] == null || response.data['admin_wallet'].isEmpty) {
          emit(DepositFailure(error: 'No wallet address provided by the server.'));
          return;
        }
        emit(DepositSuccess(responseData: response.data));
      } else {
        // Extract message from error response
        final errorMessage = response.data is Map<String, dynamic> && response.data['message'] != null
            ? response.data['message']
            : 'Failed to process deposit.';
        emit(DepositFailure(error: errorMessage));
      }
    } catch (e) {
      String errorMessage = 'An error occurred: ${e.toString()}';
      if (e is DioError && e.response != null && e.response!.data is Map<String, dynamic>) {
        errorMessage = e.response!.data['message'] ?? errorMessage;
      }
      emit(DepositFailure(error: errorMessage));
    }
  }
}

