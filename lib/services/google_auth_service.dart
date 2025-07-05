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
    //clientId: '781557174363-3su8dbkgv92h4o8u6ohue5l0j19dfqtu.apps.googleusercontent.com',
    scopes: ['openid', 'email', 'profile'],
  );
  
  final Dio _dio = GetIt.instance<Dio>();

  Future<Map<String, dynamic>?> signInWithGoogle({
    String? referralCode, 
    required BuildContext context,
    bool isLogin = false,
  }) async {
    try {
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

      // Add referral code for sign up only
      if (!isLogin && referralCode != null) {
        data['referral_code'] = referralCode;
      }

      print("Request Data: $data");

      // Select endpoint based on whether this is a login or signup
      final String endpoint = isLogin ? AppConfig.loginlink : AppConfig.registergoogle;
      print("Using endpoint: $endpoint");
      
      final response = await _dio.post(
        endpoint,
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
          
          // Save token to SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', token);
          print("Successfully saved token: $token");
          
          // Return success data and let calling code handle navigation
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
