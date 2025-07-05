import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inddigipay/bloc/loginBloc/login_bloc.dart';
import 'package:inddigipay/bloc/updatewalletBloc/updatewallet_bloc_bloc.dart';
import 'package:inddigipay/bloc/userBloc/user_bloc.dart';
import 'package:inddigipay/components/gradientoutlinedbutton.dart';
import 'package:inddigipay/config.dart';
import 'package:inddigipay/repo/auth.dart';

import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dio/dio.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<UserBloc, UserState>(
          listener: (context, state) {
            if (state is UserLoadingState) {
              setState(() {
                isLoading = true; 
              });
            } else if (state is UserSuccessState || state is UserFailureState) {
              setState(() {
                isLoading = false; 
              });
            }
          },
        ),
        BlocListener<UpdatewalletBloc, UpdatewalletBlocState>(
          listener: (context, updateState) {
            if (updateState is UpdateWalletSuccess || updateState is UpdateWalletFailure) {
              setState(() {
                isLoading = false;
              });
            }
          },
        ),
      ],
      child: Stack(
        children: [
          const ProfileAppNew(),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.6),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}



class ProfileAppNew extends StatefulWidget {
  const ProfileAppNew({super.key});

  @override
  State<ProfileAppNew> createState() => _ProfileAppNewState();
}

class _ProfileAppNewState extends State<ProfileAppNew> {
  late TextEditingController walletAddressController;

  @override
  void initState() {
    super.initState();
    walletAddressController = TextEditingController();
  }

  @override
  void dispose() {
    walletAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (context) => AuthRepo(Dio())),
        BlocProvider(
          create: (context) => UserBloc(Dio())..add(const FetchUserEvent()),
        ),
        BlocProvider(create: (context) => UpdatewalletBloc(Dio())),
        BlocProvider(create: (context) => LoginBloc(context.read<AuthRepo>())),
      ],
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          String fullName = 'No Name';
          String email = 'user@inddigi.com';

          if (state is UserSuccessState) {
            walletAddressController.text = state.user['wallet_id'] ?? '';
            fullName = state.user['full_name'] ?? 'No Name';
            email = state.user['email'] ?? 'No Email';
          }

          return Scaffold(
            extendBodyBehindAppBar: true,
            body: MultiBlocListener(
              listeners: [
                BlocListener<UpdatewalletBloc, UpdatewalletBlocState>(
                  listener: (context, updateState) {
                    if (updateState is UpdateWalletSuccess) {
                      Fluttertoast.showToast(
                        msg: "Wallet address updated successfully!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                       webBgColor: "linear-gradient(to right, #5E45CE, #5E45CE)",
                        textColor: Colors.white,
                      );
                      context.read<UserBloc>().add(const FetchUserEvent());
                    } else if (updateState is UpdateWalletFailure) {
                      Fluttertoast.showToast(
                        msg: updateState.error,
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        webBgColor: "linear-gradient(to right, #FFC1C1, #FFC1C1)",
                        textColor: Colors.white,
                      );
                    }
                  },
                ),
                BlocListener<LoginBloc, LoginState>(
                  listener: (context, state) {
                    if (state is LoginInitialState) {
                      Navigator.pushNamed(context, '/login');
                    }
                  },
                ),
              ],
              child: Container(
                height: double.infinity,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppImages.background1),
                    fit: BoxFit.cover,
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 60.sp, vertical: 30.sp),
                  child: Column(
                    children: [
                      SizedBox(height: 20.sp,),
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey,
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20.sp),
                      Text(
                        fullName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 40.sp),
                      _buildProfileInfoRow('Email id:', email),
                      _buildEditableProfileInfoRow(
                        'Trust Wallet Address:',
                        walletAddressController,
                        context,
                      ),
                      _buildProfileInfoRow('Network:', 'BSC BEP 20'),
                      SizedBox(height: 12.sp),
                      _buildActionButton('Support', () {
                        _showSupportDialog(context);
                      }),
                      SizedBox(height: 12.sp),
                      _buildActionButton('Logout', () {
                        context.read<LoginBloc>().add(LogoutEvent());
                      }),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.sp),
      child: Row(
        children: [
          Text('$label ', style: const TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableProfileInfoRow(
    String label,
    TextEditingController controller,
    BuildContext context,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.sp),
      child: Row(
        children: [
          Text('$label ', style: const TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              controller.text,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primary),
            onPressed: () => _showEditDialog(context, controller),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, TextEditingController controller) {
    final dialogController = TextEditingController(text: controller.text);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Edit Wallet Address', style: TextStyle(color: AppColors.primary,fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
          content: TextFormField(
            controller: dialogController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
              hintText: 'Enter wallet address',
              hintStyle: TextStyle(color: Colors.grey,fontSize: 12
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                final newAddress = dialogController.text.trim();
                if (newAddress.isNotEmpty && newAddress != controller.text) {
                  // Use parent context to access UpdatewalletBloc
                  context.read<UpdatewalletBloc>().add(UpdateWalletAddressEvent(newAddress: newAddress));
                  controller.text = newAddress; // Update UI immediately
                  Navigator.of(dialogContext).pop();
                  Fluttertoast.showToast(
                    msg: "Wallet address updated successfully!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                       webBgColor: "linear-gradient(to right, #5E45CE, #5E45CE)",
                  );
                } else {
                  Fluttertoast.showToast(
                    msg: "No changes made.",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                       webBgColor: "linear-gradient(to right, #5E45CE, #5E45CE)",
                  );
                }
              },
              child: const Text('Save', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: 150.sp,
      child: GradientOutlinedButton(
        onPressed: onPressed,
        text: text,
        fillColor: Colors.black,
        gradientColors: const [
          Color(0xFFFF3BFF),
          Color(0xFFECBFBF),
          Color(0xFF5C24FF),
          Color(0xFFD94FD5),
        ],
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: const Text('Need Support?', style: TextStyle(color: Colors.white)),
          content: const Text(
            'If you have any questions or need assistance, please contact us at customer.support@inddigi.com',
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }
}
class ProfileApp extends StatefulWidget {
  const ProfileApp({super.key});

  @override
  State<ProfileApp> createState() => _ProfileAppState();
}

class _ProfileAppState extends State<ProfileApp> {
  bool isEditingWalletAddress = false;
  late TextEditingController walletAddressController;

  @override
  void initState() {
    super.initState();
    walletAddressController = TextEditingController();
  }

  @override
  void dispose() {
    walletAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (context) => AuthRepo(Dio())),
        BlocProvider(
          create: (context) => UserBloc(Dio())..add(const FetchUserEvent()),
        ),
        BlocProvider(create: (context) => UpdatewalletBloc(Dio())),
        BlocProvider(create: (context) => LoginBloc(context.read<AuthRepo>())),
      ],
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          String fullName = 'No Name';
          String email = 'firstnamesurname@gmail.com';

          if (state is UserSuccessState) {
            walletAddressController.text = state.user['wallet_id'] ?? '';
            fullName = state.user['full_name'] ?? 'No Name';
            email = state.user['email'] ?? 'No Email';
          }

          return Scaffold(
            extendBodyBehindAppBar: true,
            body: MultiBlocListener(
              listeners: [
BlocListener<UpdatewalletBloc, UpdatewalletBlocState>(
  listener: (context, updateState) {
    if (updateState is UpdateWalletSuccess) {
      setState(() {
        isEditingWalletAddress = false; 
      });

      Fluttertoast.showToast(
        msg: 'Wallet address updated successfully!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } else if (updateState is UpdateWalletFailure) {
      // Handle error
      Fluttertoast.showToast(
        msg: updateState.error,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  },
),
                BlocListener<LoginBloc, LoginState>(
                  listener: (context, state) {
                    if (state is LoginInitialState) {
                      Navigator.pushNamed(context, '/login');
                    }
                  },
                ),
              ],
              child: Container(
                height: double.infinity,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppImages.background1),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 80.sp, vertical: 30.sp),
                  child: Column(
                    children: [
                      SizedBox(height: 40.sp),
                      Center(
                        child: Column(
                          children: [
                            const CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.grey,
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 20.sp),
                            Text(
                              fullName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 40.sp),
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      _buildProfileInfoRow('Email id:', email),
      _buildProfileInfoRow('Account type:', 'Investor'),
      _buildEditableProfileInfoRow(
        'Wallet Address:',
        walletAddressController,
        context,
        isEditingWalletAddress,
        () => setState(() {
          isEditingWalletAddress = !isEditingWalletAddress;
        }),
      ),
      _buildProfileInfoRow('Network:', 'BSC BEP 20'),
      SizedBox(height: 20.sp), 
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildActionAppButton('Support', () {
            _showSupportDialog(context);
          }),
          SizedBox(height: 20.sp),
          _buildActionAppButton('Logout', () {
            context.read<LoginBloc>().add(LogoutEvent());
          }),
        ],
      ),
    ],
  ),
)
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.sp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ',
            style: TextStyle(color: Colors.grey, fontSize: 16.sp),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

Widget _buildEditableProfileInfoRow(
  String label,
  TextEditingController controller,
  BuildContext context,
  bool isEditing,
  VoidCallback toggleEditing,
) {
  return Padding(
    padding: EdgeInsets.only(bottom: 16.sp),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '$label ',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16.sp,
          ),
        ),
        Expanded(
          child: isEditing
              ? TextFormField(
                  controller: controller,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                )
              : Text(
                  controller.text,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
        ),
        IconButton(
          icon: Icon(isEditing ? Icons.check : Icons.edit),
          onPressed: () {
            if (isEditing) {
              // Trigger wallet update event
              context.read<UpdatewalletBloc>().add(
                    UpdateWalletAddressEvent(newAddress: controller.text),
                  );

              // Close edit mode and reflect changes immediately
              setState(() {
                isEditingWalletAddress = false;
              });
            } else {
              toggleEditing();
            }
          },
        ),
      ],
    ),
  );
}

 Widget _buildActionAppButton(String text, VoidCallback onPressed) {
  return SizedBox(
    width: 100.sp,
    child: GradientOutlinedButton(
      onPressed: onPressed,
      text: text,
      fillColor: Colors.black,
      gradientColors: const [
        Color(0xFFFF3BFF),
        Color(0xFFECBFBF),
        Color(0xFF5C24FF),
        Color(0xFFD94FD5),
      ],
    ),
  );
}


  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return  AlertDialog(
          backgroundColor: Colors.black,
        title: Text(
          'Need Support? We’re Here to Help!',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'If you require any assistance or have questions, don’t hesitate to reach out to us. Our team is ready to provide the support you need.\n\n'
          '📧 Contact us at: customer.support@inddigi.com'
          'We’ll get back to you as soon as possible to ensure your experience with us is seamless and satisfying.\n\n'
          'Thank you for choosing us!',
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Close',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      );
      },
    );
  }
}
