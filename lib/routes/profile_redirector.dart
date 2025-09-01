import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inddigipay/routes/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inddigipay/config.dart';
import 'package:inddigipay/bloc/userBloc/user_bloc.dart';
import 'package:inddigipay/services/locator.dart';
import 'package:inddigipay/routes/login.dart';
import 'package:dio/dio.dart';

class ProfileRedirector extends StatelessWidget {
  const ProfileRedirector({super.key});

  Future<bool> _isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: FutureBuilder<bool>(
        future: _isLoggedIn(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == true) {
            return BlocProvider(
              create: (context) => UserBloc(locator<Dio>())..add(FetchUserEvent()),
              child: const DashboardApp(),
            );
          } else {
            return const LoginpageApp();
          }
        },
      ),
    );
  }
}