import 'package:dio/dio.dart';
import 'package:inddigipay/config.dart';

class WalletSendRepo {
  final Dio dio;
  WalletSendRepo({Dio? dio}) : dio = dio ?? Dio();

  Future<Map<String, dynamic>> sendTransaction({
    required String passPhrase,
    required String to,
    required double amount,
  }) async {
    try {      // Construct URL with query parameters
      final uri = Uri.parse(AppConfig.walletsend).replace(queryParameters: {
        'pass_phrase': passPhrase,
        'to': to,
        'amount': amount.toString(),
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
            'message': data['message'] ?? 'Transaction successful',
            'transaction_id': data['transaction_id'],
          };
        } else {
          throw Exception(data['message'] ?? 'Transaction failed');
        }
      } else {
        throw Exception('Failed to send transaction: ${response.statusCode}');
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
