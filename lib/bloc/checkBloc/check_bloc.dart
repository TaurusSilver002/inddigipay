import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'check_event.dart';
part 'check_state.dart';

class CheckBloc extends Bloc<CheckEvent, CheckState> {
  final Dio _dio = Dio();

  CheckBloc() : super(CheckInitial()) {
    on<CheckStatusEvent>(_onCheckStatus);
  }

  Future<void> _onCheckStatus(
    CheckStatusEvent event,
    Emitter<CheckState> emit,
  ) async {
    emit(CheckLoading());

    try {
      // Retrieve the token from shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token == null) {
        emit(CheckFailure(error: 'User not authenticated.'));
        return;
      }

      final response = await _dio.get(
        'https://api.inddigi.com/transaction/check-status?transaction_id=${event.transactionId}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        if (response.data['status'] == null) {
          emit(CheckFailure(error: 'Invalid status response from server.'));
          return;
        }
        emit(CheckSuccess(status: response.data['status']));
      } else {
        final errorMessage = response.data is Map<String, dynamic> && response.data['message'] != null
            ? response.data['message']
            : 'Failed to check transaction status.';
        emit(CheckFailure(error: errorMessage));
      }
    } catch (e) {
      String errorMessage = 'An error occurred: ${e.toString()}';
      if (e is DioError && e.response != null && e.response!.data is Map<String, dynamic>) {
        errorMessage = e.response!.data['message'] ?? errorMessage;
      }
      emit(CheckFailure(error: errorMessage));
    }
  }
}

