import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inddigipay/routes/dashboard.dart';
import 'package:inddigipay/routes/homescreen.dart';
import 'package:inddigipay/routes/login.dart';
import 'package:inddigipay/routes/wallets.dart';
import 'package:inddigipay/routes/profile_redirector.dart';
import 'package:inddigipay/services/locater.dart';
import 'package:inddigipay/bloc/transactionbloc/transaction_bloc.dart';
import 'package:inddigipay/bloc/userBloc/user_bloc.dart';
import 'package:inddigipay/bloc/wthdrawBloc/withdraw_bloc.dart';

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
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => TransactionBloc()),
            BlocProvider(create: (_) => UserBloc()),
            BlocProvider(create: (_) => WithdrawBloc()),
          ],
          child: MaterialApp(
            initialRoute: '/',
            routes: {
              '/': (context) => const HomeScreen(),
              '/dashboard': (context) => const DashboardApp(),
              '/wallets': (context) => const WalletsPage(),
              '/login': (context) => const LoginpageApp(),
              '/profile': (context) => const ProfileRedirector(),
            },
          ),
        );
      },
    );
  }
}
