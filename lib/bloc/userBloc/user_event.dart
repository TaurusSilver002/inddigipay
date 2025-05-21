part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class FetchUserEvent extends UserEvent {
  const FetchUserEvent();

  @override
  List<Object?> get props => [];
}
