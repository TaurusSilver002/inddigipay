part of 'deposit_bloc.dart';

abstract class DepositState extends Equatable {
  const DepositState();

  @override
  List<Object> get props => [];
}

class DepositInitial extends DepositState {}

class DepositLoading extends DepositState {}

class DepositSuccess extends DepositState {
  final Map<String, dynamic> responseData;

  const DepositSuccess({required this.responseData});

  @override
  List<Object> get props => [responseData];
}

class DepositFailure extends DepositState {
  final String error;

  const DepositFailure({required this.error});

  @override
  List<Object> get props => [error];
}