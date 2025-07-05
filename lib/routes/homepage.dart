
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inddigipay/bloc/walletbalanceBloc/walletbalance_bloc.dart';
import 'package:inddigipay/config.dart';

// Dummy implementation, replace with your actual fetchBNBBalance logic
Future<String> fetchBNBBalance(String? address) async {
  if (address == null || address.isEmpty) return 'No address';
  // TODO: Replace with actual API/service call
  await Future.delayed(const Duration(seconds: 1));
  return '1.2345';
}

class HomePage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<WalletbalanceBloc, WalletbalanceState>(
            builder: (context, state) {
              String? walletAddress;
              if (state is WalletbalanceLoaded) {
                walletAddress = state.address;
              } else {
                walletAddress = selectedWalletAddress;
              }
              return Column(
                children: [
                  Center(
                    child: state is WalletbalanceLoading
                        ? const CircularProgressIndicator()
                        : state is WalletbalanceLoaded
                            ? Text(
                                '\$${state.balance.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
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
                  // BNB Balance display below main balance
                  Center(
                    child: FutureBuilder<String>(
                      future: fetchBNBBalance(walletAddress),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'BNB: Error',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          );
                        } else if (snapshot.hasData) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'BNB: ${snapshot.data}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
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
                    '0%',
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
              _buildActionButton(Icons.arrow_upward, 'Send', onSendTap),
              _buildActionButton(Icons.arrow_downward, 'Receive', onReceiveTap),
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
          const Center(
            child: Text(
              'Your wallet is empty.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 16),
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
          //       'Buy Crypto',
          //       style: TextStyle(
          //         color: AppColors.textPrimary,
          //         fontSize: 16,
          //         fontWeight: FontWeight.bold,
          //       ),
          //     ),
          //   ),
          // ),
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
              onPressed: () {},
              child: const Text(
                'Manage crypto',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
            ),
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
