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
        // Debug log to see the structure of the API response
        print("Mnemonic API response structure: ${data.keys.join(', ')}");
        print("Contains private_key? ${data.containsKey('private_key')}");
        
        if (data['status'] == 'success') {
          // Create a result with all necessary fields
          final result = Map<String, dynamic>.from(data);
          
          // Check if we need to extract private key from nested data
          if (!result.containsKey('private_key') && data.containsKey('data')) {
            final nestedData = data['data'];
            if (nestedData is Map && nestedData.containsKey('private_key')) {
              result['private_key'] = nestedData['private_key'];
            }
          }
          
          return result; // Return the enhanced response
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
