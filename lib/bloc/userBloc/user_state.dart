part of 'user_bloc.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitialState extends UserState {}

class UserLoadingState extends UserState {}

class UserSuccessState extends UserState {
  final Map<String, dynamic> user;

  const UserSuccessState({required this.user});

  @override
  List<Object?> get props => [user];
}

class UserFailureState extends UserState {
  final String message;

  const UserFailureState({required this.message});

  @override
  List<Object?> get props => [message];
}
