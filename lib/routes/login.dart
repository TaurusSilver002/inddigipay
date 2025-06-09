import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:inddigipay/bloc/loginBloc/login_bloc.dart';
import 'package:inddigipay/components/custominput.dart';
import 'package:inddigipay/components/gradientoutlinedbutton.dart';
import 'package:inddigipay/config.dart';
import 'package:inddigipay/repo/auth.dart';
import 'package:inddigipay/routes/services/google.dart';

class LoginpageApp extends StatefulWidget {
  const LoginpageApp({super.key});

  @override
  State<LoginpageApp> createState() => _LoginpageAppState();
}

class _LoginpageAppState extends State<LoginpageApp> {
  late LoginBloc _loginBloc;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loginBloc = LoginBloc(GetIt.instance<AuthRepo>());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _loginBloc.close();
    super.dispose();
  }
  void _handleStateChanges(BuildContext context, LoginState state) {
    if (state is LoginLoadingState) {
      Fluttertoast.showToast(msg: 'Submitting...');
    } else if (state is LoginSuccessState) {
      Fluttertoast.showToast(msg: 'Logged in successfully!');
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else if (state is LoginFailureState) {
      Fluttertoast.showToast(
        msg: state.message.isNotEmpty ? state.message : 'Error occurred',
        webBgColor: "linear-gradient(to right, #FFC1C1, #FFC1C1)",
      );
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  Widget _buildGoogleLogin() {
    return GestureDetector(
      onTap: () async {
        try {
          Fluttertoast.showToast(msg: 'Connecting to Google...');
          final authService = GoogleAuthServiceLogin();          final userData = await authService.logInWithGoogle(context: context);
          if (userData != null) {
            Fluttertoast.showToast(msg: 'Signed in as ${userData['email']}');
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else {
            Fluttertoast.showToast(msg: 'Google Sign-In could not be completed');
          }
        } catch (e) {
          Fluttertoast.showToast(msg: 'Error: ${e.toString()}');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(8),
          color: Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AppImages.google,
              height: 10,
              width: 10,
            ),
            const SizedBox(width: 8),
            const Text(
              'Sign in with Google',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              const TextSpan(
                text: 'Welcome to the world of\n',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Transform.translate(
                  offset: const Offset(0, -4.0),
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF5827DE), Color(0xffcc4bda)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: const Text(
                      'Blockchain',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextFormFieldAppNew(
                label: 'Email',
                controller: _emailController,
                validator: _validateEmail,
                obscureText: false,
              ),
              const SizedBox(height: 16),
              CustomFieldPassAppNew(
                label: 'Enter Password',
                controller: _passwordController,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Password is required' : null,
                isPassword: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            return GradientOutlinedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _loginBloc.add(LoginUserEvent(
                    email: _emailController.text,
                    password: _passwordController.text,
                  ));
                }
              },
              text: 'Log-in',
              fillColor: Colors.black,
              gradientColors: const [
                Color(0xFFFF3BFF),
                Color(0xFFECBFBF),
                Color(0xFF5C24FF),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        _buildGoogleLogin(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _loginBloc,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.asset(
              AppImages.background2,
              fit: BoxFit.cover,
            ),

            // Login card
            Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: 360.sp, maxHeight: 600.sp),
                padding: EdgeInsets.all(16.sp),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: AssetImage(AppImages.signcardapp),
                    fit: BoxFit.cover,
                  ),
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: BlocListener<LoginBloc, LoginState>(
                      listener: _handleStateChanges,
                      child: _buildLoginForm(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
