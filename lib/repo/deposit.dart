import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inddigipay/config.dart';

class DepositApiClient {
  final http.Client client;
  final String baseUrl;

  DepositApiClient({
    required this.client,
    this.baseUrl = 'https://api.example.com',
  });

  Future<Map<String, dynamic>> deposit(double amount) async {
    final response = await client.post(
      Uri.parse(AppConfig.deposit),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'amount': amount}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to process deposit: ${response.statusCode}');
    }
  }
}

