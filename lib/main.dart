import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:inddigipay/bloc/transHistoryBloc/trans_history_bloc.dart';
import 'package:inddigipay/routes/dashboard.dart';
import 'package:inddigipay/routes/homescreen.dart';
import 'package:inddigipay/routes/homescreen_new.dart';
import 'package:inddigipay/routes/login.dart';
import 'package:inddigipay/routes/profile/profile.dart';
import 'package:inddigipay/routes/signup.dart';
import 'package:inddigipay/routes/transaction_history.dart';
import 'package:inddigipay/routes/wallets.dart';
import 'package:inddigipay/routes/profile_redirector.dart';
import 'package:inddigipay/services/locator.dart';
import 'package:inddigipay/bloc/transactionbloc/transaction_bloc.dart';
import 'package:inddigipay/bloc/userBloc/user_bloc.dart';
import 'package:inddigipay/bloc/wthdrawBloc/withdraw_bloc.dart';
import 'package:inddigipay/bloc/walletcreateBloc/walletcreate_bloc.dart';
import 'package:inddigipay/repo/walletcreate.dart';
import 'package:inddigipay/bloc/walletbalanceBloc/walletbalance_bloc.dart';
import 'package:inddigipay/repo/walletbalance.dart';

void main() {
  setupLocator(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) {        return MultiBlocProvider(
          providers: [            BlocProvider<WalletbalanceBloc>(
              create: (_) => WalletbalanceBloc(locator<WalletBalanceRepo>()),
            ),
            BlocProvider(create: (_) => TransactionBloc()),
            BlocProvider(create: (_) => UserBloc(locator<Dio>())),
            BlocProvider(create: (_) => WithdrawBloc()),
            BlocProvider(create: (_) => WalletcreateBloc(locator<WalletCreateRepo>())),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            initialRoute: '/',
            routes: {
              '/': (context) => const HomeScreen(), 
              '/myprofile': (context) => const Profile(),
              '/dashboard': (context) => const DashboardApp(),
              '/wallets': (context) => const WalletsPage(),
              '/login': (context) => const LoginpageApp(),
              '/profile': (context) => const ProfileRedirector(),
              '/signup':(context) => const SignUpApp()
            },
          ),
        );
      },
    );
  }
}
