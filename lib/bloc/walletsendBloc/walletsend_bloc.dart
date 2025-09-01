import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:inddigipay/repo/walletsend.dart';

part 'walletsend_event.dart';
part 'walletsend_state.dart';

class WalletsendBloc extends Bloc<WalletsendEvent, WalletsendState> {
  final WalletSendRepo repository;

  WalletsendBloc(this.repository) : super(WalletsendInitial()) {
    on<SendTransactionEvent>(_onSendTransaction);
  }

  Future<void> _onSendTransaction(
    SendTransactionEvent event,
    Emitter<WalletsendState> emit,
  ) async {
    emit(WalletsendLoading());

    try {
      final result = await repository.sendTransaction(
        passPhrase: event.passPhrase,
        to: event.to,
        amount: event.amount,
      );

      emit(WalletsendSuccess(
        message: result['message'] as String,
        transactionId: result['transaction_id'] as String,
      ));
    } catch (e) {
      emit(WalletsendFailure(message: e.toString()));
    }
  }
}
