import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:inddigipay/repo/walletbalance.dart';

part 'walletbalance_event.dart';
part 'walletbalance_state.dart';

class WalletbalanceBloc extends Bloc<WalletbalanceEvent, WalletbalanceState> {  final WalletBalanceRepo repository;

  WalletbalanceBloc(this.repository) : super(WalletbalanceInitial()) {
    on<FetchBalanceEvent>(_onFetchBalance);
  }

  Future<void> _onFetchBalance(
    FetchBalanceEvent event,
    Emitter<WalletbalanceState> emit,
  ) async {
    emit(WalletbalanceLoading());    int retryCount = 0;
    const maxRetries = 3;
    
    while (retryCount < maxRetries) {
      try {        // Use the address provided in the event
        final result = await repository.fetchBalance(event.address);
        final balance = double.tryParse(result['balance'].toString()) ?? 0.0;
        emit(WalletbalanceLoaded(balance: balance, address: event.address));
        return; // Success, exit the retry loop
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          emit(WalletbalanceError(message: 'Failed to fetch balance after $maxRetries attempts: ${e.toString()}'));
        } else {
          // Wait briefly before retrying
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    }
  }
}
