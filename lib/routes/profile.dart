import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inddigipay/bloc/userBloc/user_bloc.dart';
import 'package:inddigipay/config.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserSuccessState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  state.user['full_name'] ?? 'Name not available',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  state.user['email'] ?? 'Email not available',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow('Wallet ID', state.user['wallet_id'] ?? 'Not set'),
                      const SizedBox(height: 8),
                      _buildInfoRow('Referral Code', state.user['referral_code'] ?? 'Not available'),
                      const SizedBox(height: 8),
                      _buildInfoRow('Referral Balance', '\$${state.user['Referral_balance']?.toString() ?? '0.00'}'),
                      const SizedBox(height: 8),
                      _buildInfoRow('Crypto Balance', '\$${state.user['Crypto_balance']?.toString() ?? '0.00'}'),
                    ],
                  ),
                ),
              ],
            );
          } else if (state is UserLoadingState) {
            return const CircularProgressIndicator();
          } else {
            return const Text(
              'Error loading profile',
              style: TextStyle(color: Colors.red),
            );
          }
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
