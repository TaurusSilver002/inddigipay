import 'package:dio/dio.dart';
import 'package:inddigipay/config.dart';

class WalletBalanceRepo {
  final Dio dio;
  WalletBalanceRepo({Dio? dio}) : dio = dio ?? Dio();

  Future<Map<String, dynamic>> fetchBalance(String address) async {
    try {
      // Construct URL with query parameters
      final uri = Uri.parse(AppConfig.balance).replace(queryParameters: {
        'address': address,
      });
      
      final response = await dio.get(
        uri.toString(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['status'] == 'success') {
          return {
            'status': 'success',
            'balance': data['balance'],
          };
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch balance');
        }
      } else {
        throw Exception('Failed to fetch balance: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic>) {
          throw Exception(data['message'] ?? 'Network error occurred');
        }
      }
      throw Exception('Network error: ${e.message}');
    }
  }

    Future<Map<String, dynamic>> fetchBNBBalance(String address) async {
    try {
      final uri = Uri.parse(AppConfig.balance).replace(queryParameters: {
        'address': address,
        'currency': 'BNB',
      });
      
      final response = await dio.get(
        uri.toString(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['status'] == 'success') {
          return {
            'status': 'success',
            'balance': data['balance'],
          };
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch balance');
        }
      } else {
        throw Exception('Failed to fetch balance: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic>) {
          throw Exception(data['message'] ?? 'Network error occurred');
        }
      }
      throw Exception('Network error: ${e.message}');
    }
  }

}
