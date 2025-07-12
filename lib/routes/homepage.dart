import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inddigipay/bloc/walletbalanceBloc/walletbalance_bloc.dart';
import 'package:inddigipay/config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inddigipay/routes/mergecrypto.dart';
import 'package:inddigipay/utils/slide_route.dart';

Future<double?> fetchINRRate() async {
  try {
    final response = await http.get(Uri.parse('https://api.coingecko.com/api/v3/simple/price?ids=tether&vs_currencies=inr'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['tether']['inr'] as num).toDouble();
    }
    return null;
  } catch (_) {
    return null;
  }
}

// Fetch BNB balance from API
Future<String> fetchBNBBalance(String? address) async {
  if (address == null || address.isEmpty) return 'No address';
  
  try {
    // Replace with actual API endpoint for BNB balance
    final response = await http.get(Uri.parse('${AppConfig.balance}?address=$address&network=bsc'));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success' && data['data'] != null) {
        final balanceInWei = data['data'];
        // Convert from Wei to BNB (1 BNB = 10^18 Wei)
        double balanceInBNB = double.tryParse(balanceInWei.toString()) ?? 0;
        balanceInBNB = balanceInBNB / 1e18;
        return balanceInBNB.toStringAsFixed(4);
      }
    }
    // If any errors or incorrect response format, return fallback
    return '0';
  } catch (e) {
    // In case of network errors, return a fallback value
    print('Error fetching BNB balance: $e');
    return '0';
  }
}


class HomePage extends StatefulWidget {
  final String selectedWalletName;
  final String? selectedWalletAddress;
  final Function() onSendTap;
  final Function() onReceiveTap;

  const HomePage({
    Key? key,
    required this.selectedWalletName,
    required this.selectedWalletAddress,
    required this.onSendTap,
    required this.onReceiveTap,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double? inrRate;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadINRRate();
  }

  Future<void> _loadINRRate() async {
    final rate = await fetchINRRate();
    if (mounted) {
      setState(() {
        inrRate = rate;
      });
    }
    if (rate != null) {
      await _secureStorage.write(key: 'inrRate', value: rate.toString());
    }
  }

  // Get saved INR rate from secure storage
  Future<double?> getSavedINRRate() async {
    final value = await _secureStorage.read(key: 'inrRate');
    if (value == null) return null;
    return double.tryParse(value);
  }

  @override
  Widget build(BuildContext context) {
    // If inrRate is null, we could load it from storage
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<WalletbalanceBloc, WalletbalanceState>(
            builder: (context, state) {
              return Column(
                children: [
                  Center(
                    child: state is WalletbalanceLoading
                        ? const CircularProgressIndicator()
                        : state is WalletbalanceLoaded
                            ? Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '\$${state.balance.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (inrRate != null)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                                          child: Text(
                                            '≈ ₹${(state.balance * inrRate!).toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 14,
                                            ),
                                          ),
                                        )
                                      else
                                        const Padding(
                                          padding: EdgeInsets.only(left: 8.0, top: 8.0),
                                          child: SizedBox(
                                            height: 8,
                                            width: 8,
                                            child: CircularProgressIndicator(strokeWidth: 1),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              )
                            : state is WalletbalanceError
                                ? Text(
                                    'Error: ${state.message}',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                    ),
                                  )
                                : const Text(
                                    '\$0.00',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                  ),
                ],
              );
            },
          ),
          Center(
            child: BlocBuilder<WalletbalanceBloc, WalletbalanceState>(
              builder: (context, state) {
                if (state is WalletbalanceLoaded) {
                  return const Text(
                    '',
                   // '0%',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  );
                }
                return const SizedBox.shrink(); // Hide when no balance
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(Icons.arrow_upward, 'Send', widget.onSendTap),
              _buildActionButton(Icons.arrow_downward, 'Receive', widget.onReceiveTap),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Crypto',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          BlocBuilder<WalletbalanceBloc, WalletbalanceState>(
            builder: (context, state) {
              if (state is WalletbalanceLoaded) {
                // Show empty message only when balance is 0
                if (state.balance <= 0) {
                  return const Center(
                    child: Text(
                      'Your wallet is empty.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  );
                } else {
                  // Don't show any message when balance is greater than 0
                  return const SizedBox.shrink();
                }
              } else {
                // Default to showing the message if state is not loaded yet
                return const Center(
                  child: Text(
                    '',
                    style: TextStyle(
                      color: Colors.transparent,
                      fontSize: 1,
                    ),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Buy INDG',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // SizedBox(
          //   width: double.infinity,
          //   child: OutlinedButton(
          //     onPressed: () {},
          //     style: OutlinedButton.styleFrom(
          //       side: const BorderSide(color: AppColors.textSecondary),
          //       padding: const EdgeInsets.symmetric(vertical: 16),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(24),
          //       ),
          //     ),
          //     child: const Text(
          //       'Deposit Crypto',
          //       style: TextStyle(
          //         color: AppColors.textPrimary,
          
          //         fontSize: 16,
          //         fontWeight: FontWeight.bold,
          //       ),
          //     ),
          //   ),
          // ),
          // const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  SlidePageRoute(
                    page: MergeCryptoPage(
                      walletAddress: widget.selectedWalletAddress,
                    ),
                  ),
                );
              },
              child: const Text(
                'Manage crypto',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // BNB Balance Container with logo
          BlocBuilder<WalletbalanceBloc, WalletbalanceState>(
            builder: (context, state) {
              String? walletAddress;
              if (state is WalletbalanceLoaded) {
                walletAddress = state.address;
              } else {
                walletAddress = widget.selectedWalletAddress;
              }
              
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
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
                    // Circular logo with subtle gradient border
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [ Color.fromARGB(255, 234, 143, 7),  Color.fromARGB(255, 241, 92, 6)],
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
                        padding: const EdgeInsets.all(2.0), // Border width
                        child: CircleAvatar(
                          backgroundColor: Colors.black,
                          backgroundImage: const AssetImage(AppImages.bnb),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // BNB text and balance
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'BNB',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'BEP-20',
                                  style: TextStyle(
                                    color: Colors.amber,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                         
                        ],
                      ),
                    ),
                    //  FutureBuilder<String>(
                    //         future: fetchBNBBalance(walletAddress),
                    //         builder: (context, snapshot) {
                    //           if (snapshot.connectionState == ConnectionState.waiting) {
                    //             return const SizedBox(
                    //               height: 16,
                    //               width: 16,
                    //               child: CircularProgressIndicator(strokeWidth: 2),
                    //             );
                    //           } else if (snapshot.hasError) {
                    //             return const Text(
                    //               'Error loading balance',
                    //               style: TextStyle(
                    //                 color: Colors.red,
                    //                 fontSize: 12,
                    //               ),
                    //             );
                    //           } else if (snapshot.hasData) {
                    //             return Text(
                    //               snapshot.data ?? '0',
                    //               style: const TextStyle(
                    //                 color: AppColors.textSecondary,
                    //                 fontSize: 12,
                    //                 fontWeight: FontWeight.w500,
                    //               ),
                    //             );
                    //           }
                    //           return const Text(
                    //             '0',
                    //             style: TextStyle(
                    //               color: AppColors.textSecondary,
                    //               fontSize: 12,
                    //               fontWeight: FontWeight.w500,
                    //             ),
                    //           );
                    //         },
                    //       ),
                    //       const SizedBox(width: 8),
                          Text(
                            'BNB Balance:',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          FutureBuilder<String>(
                            future: fetchBNBBalance(walletAddress),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                );
                              } else if (snapshot.hasError) {
                                return const Text(
                                  'Error loading balance',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                );
                              } else if (snapshot.hasData) {
                                return Text(
                                  snapshot.data ?? '0',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              }
                              return const Text(
                                '0',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
