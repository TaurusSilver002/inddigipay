import 'package:flutter/material.dart';

import 'package:inddigipay/config.dart';


class AppbarlogApp extends StatelessWidget implements PreferredSizeWidget {
  const AppbarlogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          GestureDetector(
            onTap: (){
            },
            child: Image.asset(AppImages.logo, height: 50)),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
