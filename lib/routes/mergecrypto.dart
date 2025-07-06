import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inddigipay/config.dart';

// Model for crypto coin data
class CryptoCoin {
  final String name;
  final String symbol;
  final String imageAsset;
  final String network;

  CryptoCoin({
    required this.name,
    required this.symbol,
    required this.imageAsset,
    required this.network,
  });
}

// Fetch balance for a specific cryptocurrency
Future<String> fetchCryptoBalance(String? address, String network) async {
  if (address == null || address.isEmpty) return '0';
  
  try {
    // Replace with actual API endpoint for crypto balance
    final response = await http.get(Uri.parse('${AppConfig.balance}?address=$address&network=$network'));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success' && data['data'] != null) {
        final balanceInWei = data['data'];
        // Convert from Wei to coin (most use 10^18 decimals)
        double balanceInCrypto = double.tryParse(balanceInWei.toString()) ?? 0;
        balanceInCrypto = balanceInCrypto / 1e18;
        return balanceInCrypto.toStringAsFixed(4);
      }
    }
    return '0';
  } catch (e) {
    print('Error fetching $network balance: $e');
    return '0';
  }
}

class MergeCryptoPage extends StatefulWidget {
  final String? walletAddress;
  
  const MergeCryptoPage({
    Key? key, 
    this.walletAddress,
  }) : super(key: key);

  @override
  State<MergeCryptoPage> createState() => _MergeCryptoPageState();
}

class _MergeCryptoPageState extends State<MergeCryptoPage> {
  bool isLoading = false; // Set to false to avoid showing loading indicator
  List<CryptoCoin> supportedCoins = [];
  
  @override
  void initState() {
    super.initState();
    _loadCryptoData();
  }

  Future<void> _loadCryptoData() async {
    // Skip setting isLoading to true to avoid showing the loading indicator
    
    // Only load BNB and USDT as per requirements
    final coins = [
      CryptoCoin(
        name: 'Binance Coin',
        symbol: 'BNB',
        imageAsset: AppImages.logo,
        network: 'BEP-20',
      ),
      CryptoCoin(
        name: 'Tether',
        symbol: 'USDT',
        imageAsset: AppImages.logo,
        network: 'TRC-20',
      ),
    ];

    if (mounted) {
      setState(() {
        supportedCoins = coins;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Manage Crypto',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadCryptoData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.sp),
                    ...supportedCoins.map((coin) => _buildCryptoContainer(coin)).toList(),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  // Portfolio card and currency chip methods have been removed as they're not used in this implementation

  Widget _buildCryptoContainer(CryptoCoin coin) {
  

    return Container(
      margin: EdgeInsets.only(bottom: 12.sp),
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular logo with gradient border
          Container(
            width: 48.sp,
            height: 48.sp,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: _getColorGradientForCoin(coin.symbol),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(2.sp), // Border width
              child: CircleAvatar(
                backgroundColor: Colors.black,
                backgroundImage: AssetImage(coin.imageAsset),
              ),
            ),
          ),
          SizedBox(width: 16.sp),
          // Coin info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      coin.symbol,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8.sp),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.sp, vertical: 2.sp),
                      decoration: BoxDecoration(
                        color: _getNetworkColor(coin.network).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4.sp),
                      ),
                      child: Text(
                        coin.network,
                        style: TextStyle(
                          color: _getNetworkColor(coin.network),
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.sp),
                Text(
                  coin.name,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 8.sp),
               
              ],
            ),
          ),
          SizedBox(width: 8.sp),
          // Actions
        ],
      ),
    );
  }

  // Helper method to get colors for different coin symbols
  List<Color> _getColorGradientForCoin(String symbol) {
    switch (symbol) {
      case 'BNB':
        return [Colors.amber, Colors.amber.shade800];
      case 'ETH':
        return [Colors.blueAccent, Colors.indigo];
      case 'USDT':
        return [Colors.green, Colors.green.shade800];
      case 'INDG':
        return [AppColors.primary, Colors.deepPurple];
      default:
        return [Colors.purple, Colors.blue];
    }
  }

  // Helper method to get color for network tag
  Color _getNetworkColor(String network) {
    switch (network) {
      case 'BEP-20':
        return Colors.amber;
      case 'ERC-20':
        return Colors.blue;
      case 'TRC-20':
        return Colors.green;
      case 'Custom':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
