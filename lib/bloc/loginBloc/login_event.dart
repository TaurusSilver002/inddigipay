part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginUserEvent extends LoginEvent {
  final String email;
  final String password;

  LoginUserEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

//forgotpass
class ForgotPasswordEvent extends LoginEvent {
  final String email;

  ForgotPasswordEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

//confirmpass
class ConfirmPasswordEvent extends LoginEvent {
  final String password;
  final String token;

  ConfirmPasswordEvent({required this.password,required this.token});

  @override
  List<Object?> get props => [password,token];
}
//verify
class VerifyUserEvent extends LoginEvent{
  final String token1;
  VerifyUserEvent({required this.token1});
  @override
  List<Object?> get props=>[token1];
}

class LogoutEvent extends LoginEvent {}


