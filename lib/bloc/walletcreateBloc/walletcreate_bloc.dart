import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'walletcreate_event.dart';
part 'walletcreate_state.dart';

class WalletcreateBloc extends Bloc<WalletcreateEvent, WalletcreateState> {
  WalletcreateBloc() : super(WalletcreateInitial()) {
    on<WalletcreateEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
