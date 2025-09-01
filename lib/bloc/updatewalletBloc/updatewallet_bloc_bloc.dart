import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:inddigipay/config.dart';

import 'package:shared_preferences/shared_preferences.dart';

part 'updatewallet_bloc_event.dart';
part 'updatewallet_bloc_state.dart';

class UpdatewalletBloc extends Bloc<UpdatewalletBlocEvent, UpdatewalletBlocState> {
  final Dio dio;

  UpdatewalletBloc(this.dio) : super(UpdatewalletInitial()) {
    on<UpdateWalletAddressEvent>(_onUpdateWalletAddress);
  }

  Future<void> _onUpdateWalletAddress(
      UpdateWalletAddressEvent event, Emitter<UpdatewalletBlocState> emit) async {
    emit(UpdateWalletLoading());

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token == null) {
        emit(UpdateWalletFailure(error: 'User not authenticated.'));
        return;
      }

      final response = await dio.put(
        AppConfig.updateadd,
        data: {'wallet_id': event.newAddress},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        emit(UpdateWalletSuccess(message: response.data['message'] ?? 'Wallet address updated successfully.'));
      } else {
        emit(UpdateWalletFailure(error: response.data['message'] ?? 'Failed to update wallet address.'));
      }
    } catch (e) {
      emit(UpdateWalletFailure(error: 'An error occurred: ${e.toString()}'));
    }
  }
}
