import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inddigipay/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
  //  clientId: '781557174363-3su8dbkgv92h4o8u6ohue5l0j19dfqtu.apps.googleusercontent.com',
    scopes: ['openid', 'email', 'profile'],
  );
  
  final Dio _dio = GetIt.instance<Dio>();

  Future<Map<String, dynamic>?> signInWithGoogle({
    String? referralCode,
    required BuildContext context,
    bool isLogin = false,
  }) async {
    try {
      print('Starting Google sign in process...');
      print('Is login?: $isLogin');
      print('Referral code: $referralCode');

      // Show loading indicator
      Fluttertoast.showToast(
        msg: 'Connecting to Google...',
        webBgColor: "linear-gradient(to right, #5E45CE, #5E45CE)",
      );

      if (referralCode == null && kIsWeb) {
        final uri = Uri.base;
        referralCode = uri.queryParameters['referral_code'];
      }

      // Sign out first to ensure a fresh sign-in
      await _googleSignIn.signOut();

      // Trigger the Google sign-in flow
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        Fluttertoast.showToast(
          msg: 'Google Sign-in was cancelled',
          webBgColor: "linear-gradient(to right, #FFC1C1, #FFC1C1)",
        );
        return null;
      }

      // Get authentication details from Google
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;

      if (accessToken == null) {
        throw Exception('Access token not received from Google');
      }

      // Fetch user info using access token
      final userInfoResponse = await _dio.get(
        'https://www.googleapis.com/oauth2/v2/userinfo',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      if (userInfoResponse.statusCode != 200) {
        throw Exception('Failed to fetch user info: ${userInfoResponse.data}');
      }

      final userInfo = userInfoResponse.data;
      final String googleUserId = userInfo['id'] ?? '';
      final String userEmail = userInfo['email'] ?? '';
      final String userName = userInfo['name'] ?? '';

      if (userEmail.isEmpty) {
        throw Exception('No email address received from Google');
      }

      // Prepare data for backend
      Map<String, dynamic> data = {
        'email': userEmail,
        'password': googleUserId,
        'full_name': userName,
      };

      if (!isLogin) {
        data['referral_code'] = referralCode;
      }

      print("Sending data to backend: $data");

      // Send Google user data to backend
      final response = await _dio.post(
        isLogin ? AppConfig.loginlink : AppConfig.registergoogle,
        data: data,
        options: Options(
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      print("Response from backend: ${response.data}");

      if (response.statusCode == 200 && response.data['access_token'] != null) {
        String token = response.data['access_token'];
        
        // Save token
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);
        print("Successfully saved token: $token");
        
        return {
          'success': true,
          'email': userEmail,
          'name': userName,
          'token': token,
          'message': 'Signed in with Google successfully'
        };
      }
      
      // Handle error case
      String errorMessage = response.data['message'] ?? 'Authentication failed';
      Fluttertoast.showToast(
        msg: errorMessage,
        webBgColor: "linear-gradient(to right, #FFC1C1, #FFC1C1)",
      );
      
      return {
        'success': false,
        'message': errorMessage
      };

    } on DioException catch (e) {
      String errorMessage = 'Server error';
      
      if (e.response != null && e.response!.data != null) {
        try {
          errorMessage = e.response!.data['message'] ?? 'Server error';
        } catch (_) {
          errorMessage = 'Server error: ${e.message}';
        }
      }
      
      print("DioError: $errorMessage");
      Fluttertoast.showToast(
        msg: errorMessage,
        webBgColor: "linear-gradient(to right, #FFC1C1, #FFC1C1)",
      );
      
      return {
        'success': false,
        'message': errorMessage
      };
    } catch (error) {
      String errorMessage = 'Error during Google sign in: $error';
      print("Error: $errorMessage");
      Fluttertoast.showToast(
        msg: errorMessage,
        webBgColor: "linear-gradient(to right, #FFC1C1, #FFC1C1)",
      );
      return {
        'success': false,
        'message': errorMessage
      };
    }
  }
}
