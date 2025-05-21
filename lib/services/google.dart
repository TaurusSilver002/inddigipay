import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:flutter/services.dart';
import 'package:inddigipay/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '433334919838-fffna1ti102dvs6uskmc333rev160poj.apps.googleusercontent.com',
    scopes: ['openid', 'email', 'profile'],
  );
  
  final Dio _dio = GetIt.instance<Dio>(); // Get Dio instance from your service locator

  Future<Map<String, dynamic>?> signInWithGoogle({String? referralCode, required BuildContext context}) async {
    try {
      
      if (referralCode == null && kIsWeb) {
        final uri = Uri.base;
        referralCode = uri.queryParameters['referral_code'];
      }

      // Sign out first to ensure a fresh sign-in
      await _googleSignIn.signOut();

      // Trigger the Google sign-in flow
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      // Get authentication details from Google
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;

      if (accessToken == null) throw Exception('Access token not received');


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

      // Get user details from Google
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
        'referral_code': referralCode ?? null,
      };
    print("initiating Data: ${data}");

      // Send Google user data to backend using Dio
      final response = await _dio.post(
        AppConfig.registergoogle,
        data: data,
        options: Options(
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
    print("Response Data: ${response.data}");

      if (response.statusCode == 200) {
        
        if (response.data['access_token'] != null) {
          // Get the token
          String token = response.data['access_token'];
          
          SharedPreferences prefs = await SharedPreferences.getInstance();
await prefs.setString('access_token', token);
          print("Saved token: $token");
          // Navigate to dashboard
          Navigator.pushReplacementNamed(context, '/dashboard');
          return {
            'success': true,
            'email': userEmail,
            'name': userName,
            'token': token,
            'message': 'Signed in with Google successfully'
          };
        } else {
          throw Exception('No access token received from backend');

          
        }
      } else {
        // Handle error case
        String errorMessage = response.data['message'] ?? 'Failed to authenticate with Google';
        
        return {
          'success': false,
          'message': errorMessage
        };
      }
    } on DioException catch (e) {
      String errorMessage = 'Server error';
      
      // Extract error message from response if available
      if (e.response != null && e.response!.data != null) {
        try {
          errorMessage = e.response!.data['message'] ?? 'Server error';
        } catch (_) {
          errorMessage = 'Server error: ${e.message}';
        }
      }
      
      Fluttertoast.showToast(
        msg: errorMessage,
        webBgColor: "linear-gradient(to right, #FFC1C1, #FFC1C1)",
      );
      
      return {
        'success': false,
        'message': errorMessage
      };
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'Google sign in failed: $error',
        webBgColor: "linear-gradient(to right, #FFC1C1, #FFC1C1)",
      );
      return {
        'success': false,
        'message': 'Error during Google sign in: $error'
      };
    }
  }
} 




class GoogleAuthServiceLogin {
  static final GoogleSignIn _googleLogin = GoogleSignIn(
    clientId: '433334919838-fffna1ti102dvs6uskmc333rev160poj.apps.googleusercontent.com',
    scopes: ['openid', 'email', 'profile'],
  );
  
  final Dio _dio = GetIt.instance<Dio>(); // Get Dio instance from your service locator

  Future<Map<String, dynamic>?> logInWithGoogle({ required BuildContext context}) async {
    try {
      
     

      // Sign out first to ensure a fresh sign-in
      await _googleLogin.signOut();

      // Trigger the Google sign-in flow
      final googleUser = await _googleLogin.signIn();
      if (googleUser == null) {
        return null;
      }

      // Get authentication details from Google
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;

      if (accessToken == null) throw Exception('Access token not received');

   

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

      // Get user details from Google
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
    print("initiating Data: ${data}");

      // Send Google user data to backend using Dio
      final response = await _dio.post(
        AppConfig.loginlink,
        data: data,
        options: Options(
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json',
            'Custom-Header': 'YourHeaderValue',
          },
        ),
      );
    print("Response Data: ${response.data}");

      if (response.statusCode == 200) {
        
        if (response.data['access_token'] != null) {
          // Get the token
          String token = response.data['access_token'];
          
          SharedPreferences prefs = await SharedPreferences.getInstance();
await prefs.setString('access_token', token);
          print("Saved token: $token");
          // Navigate to dashboard
          Navigator.pushReplacementNamed(context, '/dashboard');          
          return {
            'success': true,
            'email': userEmail,
            'name': userName,
            'token': token,
            'message': 'Signed in with Google successfully'
          };
        } else {
          throw Exception('No access token received from backend');

          
        }
      } else {
        // Handle error case
        String errorMessage = response.data['message'] ?? 'Failed to authenticate with Google';
        
        return {
          'success': false,
          'message': errorMessage
        };
      }
    } on DioException catch (e) {
      String errorMessage = 'Server error';
      
      // Extract error message from response if available
      if (e.response != null && e.response!.data != null) {
        try {
          errorMessage = e.response!.data['message'] ?? 'Server error';
        } catch (_) {
          errorMessage = 'Server error: ${e.message}';
        }
      }
      
      Fluttertoast.showToast(
        msg: errorMessage,
        webBgColor: "linear-gradient(to right, #FFC1C1, #FFC1C1)",
      );
      
      return {
        'success': false,
        'message': errorMessage
      };
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'Google sign in failed: $error',
        webBgColor: "linear-gradient(to right, #FFC1C1, #FFC1C1)",
      );
      return {
        'success': false,
        'message': 'Error during Google sign in: $error'
      };
    }
  }
}