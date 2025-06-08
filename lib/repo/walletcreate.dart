import 'package:dio/dio.dart';
import 'package:inddigipay/config.dart';

class WalletCreateRepo {
  final Dio dio;
  WalletCreateRepo({Dio? dio}) : dio = dio ?? Dio();

  Future<List<Map<String, dynamic>>> fetchWalletCreate() async {
    try {
      final response = await dio.get(
        AppConfig.walletcreate,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else if (data is Map) {
          return [Map<String, dynamic>.from(data)];
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to create data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> fetchExistingWallet(String privateKeyHex) async {
    try {
      final response = await dio.get(
        AppConfig.existingwallet,
        queryParameters: {'private_key': privateKeyHex},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(response.data);
        if (data['status'] == 'success') {
          return {
            'status': 'success',
            'address': data['address'],
          };
        } else {
          throw Exception(data['message'] ?? 'Unknown error occurred');
        }
      } else {
        throw Exception('Failed to get wallet: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 503) {
        final message = e.response?.data['message'] ?? 'Service unavailable';
        throw Exception(message);
      }
      throw Exception('Network error: ${e.message}');
    }
  }
    Future<Map<String, dynamic>> fetchByMnemonic(String mnemonic) async {
    try {
      final response = await dio.post(
        AppConfig.mnemonic,
        data: {'mnemonic': mnemonic},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['status'] == 'success') {
          return Map<String, dynamic>.from(data); // Return the complete response
        } else {
          throw Exception(data['message'] ?? 'Failed to retrieve wallet');
        }
      } else {
        throw Exception('Failed to retrieve wallet: ${response.statusCode}');
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
