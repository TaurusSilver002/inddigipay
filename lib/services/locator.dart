import 'package:get_it/get_it.dart';
import 'package:inddigipay/repo/walletbalance.dart';
import 'package:inddigipay/repo/walletcreate.dart';
import 'package:inddigipay/repo/walletsend.dart';

final locator = GetIt.instance;

void setupLocator() {
  // Register repositories
  locator.registerLazySingleton<WalletBalanceRepo>(() => WalletBalanceRepo());
  locator.registerLazySingleton<WalletCreateRepo>(() => WalletCreateRepo());
  locator.registerLazySingleton<WalletSendRepo>(() => WalletSendRepo());
}
