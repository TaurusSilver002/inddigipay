import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inddigipay/config.dart';

class AuthRepo {
  final Dio _dio;

  AuthRepo(this._dio);



Future<String?> registerUser({
  required String email,
  required String password,
  required String name,
  String? referralCode,
}) async {
  try {
    Map<String, dynamic> data = {
      'email': email,
      'password': password,
      'full_name': name,
      'referral_code': referralCode ?? '',
    };

    final response = await _dio.post(
      AppConfig.signlink,
      data: data,
      options: Options(
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // ✅ Debugging: Print the full response from backend
    print("Response Data: ${response.data}");

    if (response.statusCode == 200) {
      return null; // Registration successful, return no error
    } else {
      return response.data["message"] ?? "Unknown error occurred"; // Extract error message
    }
  } on DioException catch (e) {
    if (e.response != null) {
      // ✅ Debugging: Print the full error response
      print("Error Response Data: ${e.response?.data}");

      return e.response?.data["message"] ?? "Something went wrong.";
    } else {
      return "No response from server. Check your internet connection.";
    }
  } catch (e) {
    return "Unexpected error: ${e.toString()}";
  }
}


  
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      Map<String, dynamic> data = {
        'email': email,
        'password': password,
      };

      final response = await _dio.post(
        AppConfig.loginlink,
        data: data,
        options: Options(
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        String token = response.data['access_token'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', token);

      return token;
      } else {
        return null;
      }
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }  //forgotpass
    Future<bool> forgotPassword({required String email}) async {
    try {
      Map<String, dynamic> data = {
        'email': email,
      };

      final response = await _dio.post(
        AppConfig.forgotpass,
        data: data,
        options: Options(
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error during password reset: $e");
      return false;
    }
  }

//confirmpass
    Future<bool> confirmPassword({required String password ,required String token}) async {
    try {
      Map<String, dynamic> data = {
        'new_password': password,
        'token': token,
      };

      final response = await _dio.post(
        AppConfig.confirmpass,
        data: data,
        options: Options(
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error during password reset: $e");
      return false;
    }
  }
//verify 

    Future<bool> verifyUser({required String token1}) async {
    try {
      Map<String, dynamic> data = {
        'token': token1,
      };

      final response = await _dio.post(
        AppConfig.verifyuser,
        data: data,
        options: Options(
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error during password reset: $e");
      return false;
    }
  }

}
