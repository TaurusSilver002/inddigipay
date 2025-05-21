import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:inddigipay/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final Dio _dio = Dio();

  UserBloc() : super(UserInitialState()) {
    on<FetchUserEvent>(_onFetchUser);
  }

  Future<void> _onFetchUser(FetchUserEvent event, Emitter<UserState> emit) async {
    emit(UserLoadingState());

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token == null) {
        emit(const UserFailureState(message: 'User not authenticated.'));
        return;
      }

      final response = await _dio.get(
        AppConfig.user, 
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        print(response.data);

        emit(UserSuccessState(user: response.data));
      } else {
        emit(const UserFailureState(message: 'Failed to load user data.'));
      }
    } catch (e) {
      emit(UserFailureState(message: 'An error occurred: ${e.toString()}'));
    }
  }
}
