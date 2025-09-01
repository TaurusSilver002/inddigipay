import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:inddigipay/config.dart';
import 'package:inddigipay/repo/auth.dart';
import 'package:inddigipay/repo/walletcreate.dart';
import 'package:inddigipay/repo/walletsend.dart';
import 'package:inddigipay/repo/walletbalance.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<Dio>(() {
    Dio dio = Dio();
    dio.options.baseUrl = AppConfig.baseurl;
    return dio;
  });
  locator.registerLazySingleton<AuthRepo>(() => AuthRepo(locator<Dio>()));
  locator.registerLazySingleton<WalletCreateRepo>(() => WalletCreateRepo(dio: locator<Dio>()));
  locator.registerLazySingleton<WalletSendRepo>(() => WalletSendRepo(dio: locator<Dio>()));
  locator.registerLazySingleton<WalletBalanceRepo>(() => WalletBalanceRepo(dio: locator<Dio>()));
}
