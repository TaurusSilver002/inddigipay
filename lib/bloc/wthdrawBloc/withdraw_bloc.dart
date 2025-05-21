import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:inddigipay/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'withdraw_event.dart';
part 'withdraw_state.dart';

class WithdrawBloc extends Bloc<WithdrawEvent, WithdrawState> {
  final Dio _dio = Dio();

  WithdrawBloc() : super(WithdrawInitial()) {
    on<WithdrawRequestEvent>(_onWithdrawRequest);
  }

  Future<void> _onWithdrawRequest(
      WithdrawRequestEvent event, Emitter<WithdrawState> emit) async {
    emit(WithdrawLoading());

    try {
      // Retrieve the token from shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token == null) {
        emit(WithdrawFailure(error: 'User not authenticated.'));
        return;
      }

      final response = await _dio.post(
        AppConfig.wallet, 
        data: {'amount': event.amount},
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
        emit(WithdrawSuccess(responseData: response.data));
      } else {
        emit(WithdrawFailure(error: 'Failed to process withdrawal.'));
      }
    } catch (e) {
      emit(WithdrawFailure(error: 'An error occurred: ${e.toString()}'));
    }
  }
}
