import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:inddigipay/repo/walletcreate.dart';

part 'walletcreate_event.dart';
part 'walletcreate_state.dart';

class WalletcreateBloc extends Bloc<WalletcreateEvent, WalletcreateState> {
  final WalletCreateRepo repository;

  WalletcreateBloc(this.repository) : super(WalletcreateInitial()) {
    on<FetchWalletCreate>(_onFetchWalletCreate);
  }

  Future<void> _onFetchWalletCreate(
    FetchWalletCreate event,
    Emitter<WalletcreateState> emit,
  ) async {
    emit(WalletcreateLoading());
    try {
      final data = await repository.fetchWalletCreate();
      emit(WalletcreateLoaded(data));
    } catch (e) {
      emit(WalletcreateError(e.toString()));
    }
  }
}
