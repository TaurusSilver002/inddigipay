import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:inddigipay/config.dart';
import 'package:inddigipay/repo/auth.dart';
import 'package:inddigipay/repo/walletbalance.dart';
import 'package:inddigipay/repo/walletcreate.dart';
import 'package:inddigipay/repo/walletsend.dart';

final locator = GetIt.instance;

void setupLocator() {
  // Register Dio instance
  locator.registerLazySingleton<Dio>(() {
    Dio dio = Dio();
    dio.options.baseUrl = AppConfig.baseurl;
    return dio;
  });

  // Register repositories
  locator.registerLazySingleton<AuthRepo>(() => AuthRepo(locator<Dio>()));
  locator.registerLazySingleton<WalletBalanceRepo>(() => WalletBalanceRepo());
  locator.registerLazySingleton<WalletCreateRepo>(() => WalletCreateRepo());
  locator.registerLazySingleton<WalletSendRepo>(() => WalletSendRepo());
}
