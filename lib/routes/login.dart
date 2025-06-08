  import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:inddigipay/bloc/loginBloc/login_bloc.dart';
import 'package:inddigipay/components/custominput.dart';
import 'package:inddigipay/components/customnav.dart';
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
  int _currentIndex = 0;

void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
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

  bool passToggle = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      
      body: BlocProvider(
        create: (_) => _loginBloc,
        child: Container(
         padding: EdgeInsets.symmetric(horizontal: 16.sp),

          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppImages.background1),//here
              fit: BoxFit.cover,
            ),
          ),
          alignment: Alignment.center,
          child: Container(
            height: 500.sp,
               // width: 800.sp,
             constraints: BoxConstraints(maxWidth: 400.sp, minWidth: 300.sp,maxHeight: 550.sp,minHeight: 500.sp),
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage(AppImages.signcardapp),
              fit: BoxFit.fill),
            ),
             alignment: Alignment.topLeft,
            child: Container(
             // color: Colors.red,
              constraints: BoxConstraints(maxWidth: 400.sp, minWidth: 300.sp),
               padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.08 + 2,
                  top: 35,right: 30),
              child: Form(
              key: _formKey,
               autovalidateMode: AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                
                  children: [
                
                     Container(
                      alignment: Alignment.center,
                       child: RichText(
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
                                          colors: [
                                            Color(0xFF5827DE),
                                            Color(0xffcc4bda)
                                          ],
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
                     ),
                          const SizedBox(
                      height: 50,
                    ),
                    CustomTextFormFieldAppNew(label: 'Email', controller: _emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        // Regex for email validation
                        final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                     obscureText: false),

                     const SizedBox(
                    height: 16,
                                        ),                  
                    
                       CustomFieldPassAppNew(
                      label: 'Enter Password',
                      controller: _passwordController,
                      validator: (value) =>
                          value == null || value.isEmpty
                              ? 'Password is required'
                              : null,
                     // obscureText: true,
                      isPassword: true,
                      
                    ),
                            
                    const SizedBox(height: 70),
                    // login button
                    BlocListener<LoginBloc, LoginState>(
                      listener: (context, state) {
                        if (state is LoginLoadingState) {
                          Fluttertoast.showToast(msg: 'Submitting...',
                              webBgColor: "linear-gradient(to right, #5E45CE, #5E45CE)",

                          );
                        }
                        else if (state is LoginSuccessState) {
                          Fluttertoast.showToast(msg: 'Logged in successfully!',
                             webBgColor: "linear-gradient(to right, #5E45CE, #5E45CE)",
                          );
                          Navigator.pushReplacementNamed(context, '/dashboard');
                        }
                        else if (state is LoginFailureState) {
                          Fluttertoast.showToast(msg: state.message ?? 'Error occurred',
                           webBgColor: "linear-gradient(to right, #FFC1C1, #FFC1C1)",

                          );
                        }
                      },
                      child: BlocBuilder<LoginBloc, LoginState>(
                        builder: (context, state) {
                          return Center(
                            child: GradientOutlinedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _loginBloc.add(
                                    LoginUserEvent(email: _emailController.text,
                                     password: _passwordController.text)
                                  );
                                }else{
                                  print('form invalid');
                                }
                              },
                              text: 'Log-in',
                              fillColor: Colors.black,
                              gradientColors: const [
                                Color(0xFFFF3BFF),
                                Color(0xFFECBFBF),
                                Color(0xFF5C24FF),
                                Color(0xFFD94FD5),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: "Forgot password ",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                              },
                          ),
                          const TextSpan(
                            text: "   ",
                          ),
                          TextSpan(
                            text: "Sign-up",
                            style: const TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                              },
                          )
                        ],
                      ),
                    ),
                                        ),
                    SizedBox(height: 8.sp),
                   // Inside your SignUpWeb class, replace the Google Sign-In GestureDetector with this:
Center(
  child: GestureDetector(
    onTap: () async {
      try {
        // Show loading toast
        Fluttertoast.showToast(
          msg: 'Connecting to Google...',
          webBgColor: "linear-gradient(to right, #5E45CE, #5E45CE)",
        );
        
        final authService = GoogleAuthServiceLogin();
        final userData = await authService.logInWithGoogle(context: context);
        if (userData != null) {
          // Successfully signed in
          Fluttertoast.showToast(
            msg: 'Signed in as ${userData['email']}',
            webBgColor: "linear-gradient(to right, #5E45CE, #5E45CE)",
          );
          
          // Navigate to dashboard or whatever page should come after successful sign-in
          // context.go("/dashboard"); // Update this to your appropriate route
        } else {
          // Sign-in failed or was cancelled
          Fluttertoast.showToast(
            msg: 'Google Sign-In could not be completed',
            webBgColor: "linear-gradient(to right, #FFC1C1, #FFC1C1)",
          );
        }
      } catch (e) {
        // Handle any unexpected errors
        Fluttertoast.showToast(
          msg: 'Error: ${e.toString()}',
          webBgColor: "linear-gradient(to right, #FFC1C1, #FFC1C1)",
        );
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
            'Signin with Google',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    ),
  ),
)    ,
  
        
                  ],
                ),
              ),
            ),
          ),
        ),
        
      ),
      bottomNavigationBar: CustomBottomNavBar(
              currentIndex: _currentIndex,
              onTap: _onNavTap,
            ),
    );
  }
}

