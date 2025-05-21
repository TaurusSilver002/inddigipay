
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inddigipay/repo/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';


part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent,LoginState>{
  final AuthRepo _authRepo;
  LoginBloc(this._authRepo):super(LoginInitialState()){
    on<LoginUserEvent>(_onlogin);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<ConfirmPasswordEvent>(_onConfirmPassword);
    on<LogoutEvent>(_onLogout); 
    on<VerifyUserEvent>( _onVerifyUserPassword);

  }
Future<void> _onlogin(LoginUserEvent event, Emitter<LoginState> emit) async {
  emit(LoginLoadingState());
  try {
    String? accessToken = await _authRepo.loginUser(email: event.email, password: event.password);

    if (accessToken != null && accessToken.isNotEmpty) {
      print("Access Token: $accessToken");
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', accessToken);
      emit(LoginSuccessState(token: accessToken));
    } else {
      emit(const LoginFailureState(message: 'Login failed, please try again.'));
    }
  } catch (e) {
    emit(LoginFailureState(message: 'An error occurred: ${e.toString()}'));
  }
}
//logout
 Future<void> _onLogout(LogoutEvent event, Emitter<LoginState> emit) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token'); 
      emit(LoginInitialState());
    } catch (e) {
      emit(LoginFailureState(message: 'Logout failed: ${e.toString()}'));
    }
  }
  //forgotpass
Future<void> _onForgotPassword(ForgotPasswordEvent event, Emitter<LoginState> emit) async {
    emit(ForgotPasswordLoadingState());
    try {
      bool isSuccess = await _authRepo.forgotPassword(email: event.email);

      if (isSuccess) {
        emit(ForgotPasswordSuccessState());
      } else {
        emit(const ForgotPasswordFailureState(message: 'Password reset failed, please try again.'));
      }
    } catch (e) {
      emit(ForgotPasswordFailureState(message: 'An error occurred: ${e.toString()}'));
    }
  }

  //confirmpass
  Future<void> _onConfirmPassword(ConfirmPasswordEvent event, Emitter<LoginState> emit) async {
  emit(ConfirmPasswordLoadingState());
  try {
    bool isSuccess = await _authRepo.confirmPassword(password: event.password,token: event.token);

    if (isSuccess) {
      emit(ConfirmPasswordSuccessState());
    } else {
      emit(const ConfirmPasswordFailureState(message: 'Password confirmation failed, please try again.'));
    }
  } catch (e) {
    emit(ConfirmPasswordFailureState(message: 'An error occurred: ${e.toString()}'));
  }
}

//verify
  Future<void> _onVerifyUserPassword(VerifyUserEvent event, Emitter<LoginState> emit) async {
  emit(VerifyUserLoadingState());
  try {
    bool isSuccess = await _authRepo.verifyUser(token1: event.token1);

    if (isSuccess) {
      emit(VerifyUserSuccessState());
    } else {
      emit(const VerifyUserFailureState(message: 'Verification failed, please try again.'));
    }
  } catch (e) {
    emit(VerifyUserFailureState(message: 'An error occurred: ${e.toString()}'));
  }
}

}