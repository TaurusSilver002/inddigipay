part of 'check_bloc.dart';

abstract class CheckState extends Equatable {
  const CheckState();

  @override
  List<Object> get props => [];
}

class CheckInitial extends CheckState {}

class CheckLoading extends CheckState {}

class CheckSuccess extends CheckState {
  final int status;

  const CheckSuccess({required this.status});

  @override
  List<Object> get props => [status];
}

class CheckFailure extends CheckState {
  final String error;

  const CheckFailure({required this.error});

  @override
  List<Object> get props => [error];
}
