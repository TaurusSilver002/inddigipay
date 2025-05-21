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
      actions: [
        TextButton(
          onPressed: () {
          },
          child: const Text('Home',      
                style: TextStyle(color: Colors.white,fontSize: 12),
),
        ),
        TextButton(
          onPressed: () {
          },
          child: const Text('Profile',
                style: TextStyle(color: Colors.white,fontSize: 12),
),
        ),
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey[200],
          child: const Icon(
            Icons.person,
            size: 16,
            color: Colors.grey,
          ),
        ),
        SizedBox(width: 8,)
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60.0);}
