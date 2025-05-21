part of 'withdraw_bloc.dart';

sealed class WithdrawState extends Equatable {
  const WithdrawState();

  @override
  List<Object> get props => [];
}

final class WithdrawInitial extends WithdrawState {}

class WithdrawLoading extends WithdrawState {}

class WithdrawSuccess extends WithdrawState {
  final Map<String, dynamic> responseData;

  const WithdrawSuccess({required this.responseData});

  @override
  List<Object> get props => [responseData];
}

class WithdrawFailure extends WithdrawState {
  final String error;

  const WithdrawFailure({required this.error});

  @override
  List<Object> get props => [error];
}
