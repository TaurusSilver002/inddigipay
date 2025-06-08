part of 'walletsend_bloc.dart';

abstract class WalletsendState extends Equatable {
  const WalletsendState();
  
  @override
  List<Object> get props => [];
}

class WalletsendInitial extends WalletsendState {}

class WalletsendLoading extends WalletsendState {}

class WalletsendSuccess extends WalletsendState {
  final String message;
  final String transactionId;

  const WalletsendSuccess({
    required this.message,
    required this.transactionId,
  });

  @override
  List<Object> get props => [message, transactionId];
}

class WalletsendFailure extends WalletsendState {
  final String message;

  const WalletsendFailure({required this.message});

  @override
  List<Object> get props => [message];
}
