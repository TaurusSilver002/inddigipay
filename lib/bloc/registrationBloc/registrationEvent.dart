part of 'registrationBloc.dart';

abstract class RegistrationEvent extends Equatable {
  const RegistrationEvent();

  @override
  List<Object?> get props => [];
}

class RegistrationCreateUserEvent extends RegistrationEvent {
  final String email;
  final String password;
  final String name;
  final String? referralCode;

  RegistrationCreateUserEvent({
    required this.email,
    required this.password,
    required this.name,
    required this.referralCode,
  });

  @override
  List<Object?> get props => [email, password, name, referralCode];
}
