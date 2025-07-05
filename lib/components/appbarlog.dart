import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:inddigipay/bloc/loginBloc/login_bloc.dart';
import 'package:inddigipay/bloc/updatewalletBloc/updatewallet_bloc_bloc.dart';
import 'package:inddigipay/bloc/userBloc/user_bloc.dart';
import 'package:inddigipay/config.dart';
import 'package:inddigipay/repo/auth.dart';
import 'package:inddigipay/routes/profile/profile.dart';

class AppbarlogApp extends StatelessWidget implements PreferredSizeWidget {
  const AppbarlogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: (){
              // Logo tap action if needed
            },
            child: Image.asset(AppImages.logo, height: 50),
          ),
          
          GestureDetector(
            onTap: () {
              // Navigate directly to Profile with all required BlocProviders
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => MultiBlocProvider(
                    providers: [
                      BlocProvider(create: (context) => UserBloc(Dio())..add(const FetchUserEvent())),
                      BlocProvider(create: (context) => UpdatewalletBloc(Dio())),
                      BlocProvider(create: (context) => LoginBloc(AuthRepo(Dio()))),
                    ],
                    child: const Profile(),
                  ),
                )
              );
            },
            child: Icon(Icons.person, size: 30, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
