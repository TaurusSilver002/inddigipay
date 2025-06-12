import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:inddigipay/bloc/registrationBloc/registrationBloc.dart';
import 'package:inddigipay/components/custominput.dart';
import 'package:inddigipay/components/gradientoutlinedbutton.dart';
import 'package:inddigipay/config.dart';
import 'package:inddigipay/repo/auth.dart';
import 'package:inddigipay/routes/login.dart';
import 'package:inddigipay/routes/services/google.dart';
import 'package:inddigipay/utils/route_transitions.dart';

class SignUpApp extends StatefulWidget {
  const SignUpApp({super.key});

  @override
  State<SignUpApp> createState() => _SignUpAppState();
}

class _SignUpAppState extends State<SignUpApp> {
  late RegistrationBloc _registrationBloc; 
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _referralCodeController = TextEditingController();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  final _isPasswordMatchNotifier = ValueNotifier<bool>(true);

  bool _isPasswordMatch = true;
String? referralCode;

@override
void initState() {
  super.initState();
  _registrationBloc = RegistrationBloc(GetIt.instance<AuthRepo>());

  final uriFragment = Uri.base.fragment;
  final uri = Uri.parse('https://fake.com/?${uriFragment.split('?').last}');

  referralCode = uri.queryParameters['referral_code'];
  if (referralCode != null) {
    _referralCodeController.text = referralCode!;
  }
}


  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referralCodeController.dispose();
    _confirmPasswordFocusNode.dispose();
    _registrationBloc.close();  
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      body: BlocProvider(
        create: (_) => _registrationBloc,  
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.sp),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppImages.background2),
              fit: BoxFit.cover,
            ),
          ),
          alignment: Alignment.center,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 400.sp,
              minWidth: 300.sp,
              maxHeight: 550.sp,
              minHeight: 500.sp,
            ),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.signcardapp),
                fit: BoxFit.fill,
              ),
            ),
            alignment: Alignment.topLeft,
            child: Container(
              constraints: BoxConstraints(maxWidth: 400.sp, minWidth: 300.sp),
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.08 + 2,
                top: 35,
                right: 50,
              ),
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
                    // Name field
                    CustomTextFormFieldAppNew(
                      label: 'Name',
                      controller: _nameController,
                      validator: (value) =>
                          value == null || value.isEmpty
                              ? 'Name is required'
                              : null,
                      obscureText: false,
                     
                    ),
                    const SizedBox(height: 16),

                    // Email field
                    CustomTextFormFieldAppNew(
                      label: 'Email',
                      controller: _emailController,
                      validator: (value) =>
                          value == null || value.isEmpty
                              ? 'Email is required'
                              : null,
                      obscureText: false,
                     
                    ),
                    const SizedBox(height: 16),

                    // Password field
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
                    const SizedBox(height: 16),

                    // Confirm Password field
                    CustomFieldPassAppNew(
                      label: 'Confirm Password',
                      controller: _confirmPasswordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirm password is required';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                     // obscureText: true,
                      isPassword: true,
                     
                    ),
                    const SizedBox(height: 16),

                    // Referral Code field
                    CustomTextFormFieldAppNew(
                      label: 'Referral Code',
                      controller: _referralCodeController,
                      validator:(value) =>
                          value == null || value.isEmpty
                              ? 'Referral Code is required'
                              : null,
                      obscureText: false,
                    ),
                    const SizedBox(height: 24),

                    // Sign Up button
                    BlocListener<RegistrationBloc, RegistrationState>(
                      listener: (context, state) {
                        if (state is RegistrationLoadingState) {
                          Fluttertoast.showToast(msg: 'Submitting...',
                           webBgColor: "linear-gradient(to right, #5E45CE, #5E45CE)",

                          );
                        } else if (state is RegistrationSuccessState) {
                          Fluttertoast.showToast(msg: 'Email sent successfully!',
                            webBgColor: "linear-gradient(to right, #5E45CE, #5E45CE)",
                          );
                        } else if (state is RegistrationFailedState) {
                          Fluttertoast.showToast(msg: state.message ?? 'Error occurred',
                        webBgColor: "linear-gradient(to right, #FFC1C1, #FFC1C1)",
                          );
                        }
                      },
                      child: BlocBuilder<RegistrationBloc, RegistrationState>(
                        builder: (context, state) {
                          return Center(
                            child: GradientOutlinedButton(
                              text: 'Sign up',
                              fillColor: Colors.black,
                              gradientColors: const [
                                Color(0xFFFF3BFF),
                                Color(0xFFECBFBF),
                                Color(0xFF5C24FF),
                                Color(0xFFD94FD5),
                              ],
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<RegistrationBloc>().add(RegistrationCreateUserEvent(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                    name: _nameController.text,
                                    referralCode: _referralCodeController.text,
                                  ));
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Login suggestion at the bottom
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: "Already have an account? ",
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                          children: [
                            TextSpan(
                              text: "Login",
                              style: const TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()..onTap = () {
                               Navigator.of(context).push(
                      SlidePageRoute(page:  LoginpageApp())
                    ); // Update this to your login route
                              },
                            ),
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
        
        final authService = GoogleAuthService();
        final userData = await authService.signInWithGoogle(referralCode: referralCode,context: context);
        
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            height: 12,
            width: 12,
          ),
          const SizedBox(width: 4),
          const Text(
            'Sign up with Google',
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
)                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
