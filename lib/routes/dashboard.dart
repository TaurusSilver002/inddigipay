import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inddigipay/bloc/transactionbloc/transaction_bloc.dart';
import 'package:inddigipay/bloc/userBloc/user_bloc.dart';
import 'package:inddigipay/bloc/wthdrawBloc/withdraw_bloc.dart';
import 'package:inddigipay/components/appbarlog.dart';
import 'package:inddigipay/components/gradientoutlinedbutton.dart';
import 'package:inddigipay/config.dart';
import 'package:inddigipay/routes/dashboardcards/deposit.dart';
import 'package:inddigipay/routes/dashboardcards/referpage.dart';
import 'package:inddigipay/routes/dashboardcards/transactions.dart';
import 'package:inddigipay/routes/dashboardcards/withdrawl.dart';

class DashboardApp extends StatefulWidget {
  const DashboardApp({super.key});

  @override
  State<DashboardApp> createState() => _DashboardAppState();
}

class _DashboardAppState extends State<DashboardApp> {
  @override
  void initState() {
    super.initState();
    context
        .read<TransactionBloc>()
        .add(const FetchTransactionEvent(page: 1, limit: 3));
    context.read<UserBloc>().add(FetchUserEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const AppbarlogApp(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Section
            Container(
              constraints: const BoxConstraints(minWidth: 2000),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppImages.background1),
                  fit: BoxFit.cover,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<UserBloc, UserState>(
                    builder: (context, state) {
                      if (state is UserSuccessState) {
                        String name =
                            state.user['full_name'] ?? 'Name not available';
                        return Text(
                          name,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        );
                      } else if (state is UserLoadingState) {
                        return const Center(child: CircularProgressIndicator());
                      } else {
                        return const Text(
                          'Name not available',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Network: ', style: TextStyle(color: Colors.grey)),
                      Text('BSC BEP 20',
                          style: TextStyle(color: Colors.blueAccent)),
                      SizedBox(width: 20),
                      Text('Account type: ',
                          style: TextStyle(color: Colors.grey)),
                      Text('Investor',
                          style: TextStyle(color: Colors.purpleAccent)),
                    ],
                  ),
                  const SizedBox(height: 50),

                  // Cards Section
                  _buildCardsSection(),

                  const SizedBox(height: 40),
                ],
              ),
            ),

            // Transaction Section
            Container(
              padding: const EdgeInsets.all(20),
              color: const Color(0xFF0e0e0e),
              child: Column(
                children: [
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<TransactionBloc, TransactionState>(
                    builder: (context, state) {
                      if (state is TransactionLoadingState) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is TransactionSuccessState) {
                        return TransactionsPage(
                            transactions: state.transactions);
                      } else if (state is TransactionFailureState) {
                        return Center(
                          child: Text(
                            'Error: ${state.message}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }
                      return const Center(
                        child: Text(
                          'No transactions available.',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                    },
                    child: const Text(
                      'View more',
                      style: TextStyle(
          color: AppColors.primary,
                        decoration: TextDecoration.underline,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),

            // Footer
          ],
        ),
      ),
    );
  }

  Widget _buildCardsSection() {
    return Column(
      children: [
        // First Row of Cards
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Deposit Card
            BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserSuccessState) {
                  String cryptoBalance =
                      state.user['Crypto_balance']?.toString() ?? 'N/A';
                  String? walletId = state.user['wallet_id'];

                  return _buildCard(
                    context: context,
                    title: 'Deposit',
                    mainText: cryptoBalance,
                    subtitleText: 'Crypto Wallet',
                    onPressed: () {
                      if (walletId != null && walletId.isNotEmpty) {
                        _showDepositDialog(context);
                      } else {
                        _addWalletDialog(context);
                      }
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
            // Withdraw Card
            BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                String referralBalance = '0.00';
                String? walletId;

                if (state is UserSuccessState) {
                  referralBalance =
                      state.user['Referral_balance']?.toString() ?? '0.00';
                  walletId = state.user['wallet_id'];
                }

                return _buildCard(
                  context: context,
                  title: 'Withdraw',
                  mainText: referralBalance,
                  subtitleText: 'Referral Wallet',
                  onPressed: () {
                    if (walletId != null && walletId.isNotEmpty) {
                      _showWithdrawlDialog(context, walletId, referralBalance);
                    } else {
                      _addWalletDialog(context);
                    }
                  },
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Second Row of Cards
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Refer Now Card
            BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserSuccessState) {
                  String referralCode = state.user['referral_code'] ?? 'N/A';
                  String hierarchyCount =
                      state.user['hierarchy_count']?.toString() ?? '0';

                  return _buildCard(
                    context: context,
                    title: 'Refer Now',
                    mainText: hierarchyCount,
                    subtitleText: 'Total Referrals',
                    onPressed: () {
                      _showReferNowDialog(context, referralCode);
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
            // Transfer Card
            BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserSuccessState) {
                  final List<Map<String, dynamic>> levelCounts =
                      (state.user['level_count'] as List<dynamic>)
                          .map((e) => e as Map<String, dynamic>)
                          .toList();

                  // Filter levels with count > 0
                  final filteredLevels =
                      levelCounts.where((level) => level['count'] > 0).toList();

                  if (filteredLevels.isNotEmpty) {
                    // Sort the filtered levels by level in descending order
                    filteredLevels
                        .sort((a, b) => b['level'].compareTo(a['level']));
                    final highestLevel = filteredLevels.first;

                    return _buildCard(
                      context: context,
                      title: 'View',
                      mainText: '${highestLevel['count']}',
                      subtitleText: 'Highest level: ${highestLevel['level']}',
                      onPressed: () {
                        _showLevelsDialog(context, levelCounts);
                      },
                    );
                  } else {
                    // If no levels have count > 0, show a placeholder card
                    return _buildCard(
                      context: context,
                      title: 'No Levels',
                      mainText: '0',
                      subtitleText: 'No level data available',
                      onPressed: () {
                        _showLevelsDialog(context, levelCounts);
                      },
                    );
                  }
                }
                return const CircularProgressIndicator();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required String title,
    required String mainText,
    required String subtitleText,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        color: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          width: 150.sp,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                mainText,
                style: const TextStyle(color: AppColors.primary, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                subtitleText,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              GradientOutlinedButton(
                onPressed: onPressed,
                text: title,
                gradientColors: const [
                  Color(0xFFFF3BFF),
                  Color(0xFFECBFBF),
                  Color(0xFF5C24FF),
                  Color(0xFFD94FD5),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDepositDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 800.w,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color: AppColors.primary,
                  width: 1,
                ),
              ),
              child: const DepositWeb(
                walletAddress: '0x1B82EF632f8BEE5B50354fD2a2B0FABC26e5a18f',
              ),
            ),
          ),
        );
      },
    );
  }

  void _showWithdrawlDialog(
      BuildContext context, String walletId, String referralBalance) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return BlocProvider(
          create: (context) => WithdrawBloc(),
          child: Builder(
            builder: (context) => Center(
              child: Dialog(
                backgroundColor: Colors.transparent,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Material(
                      color: Colors.black,
                      child: WithdrawlWeb(
                        walletAddress: walletId,
                        referralBalance: referralBalance,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showReferNowDialog(BuildContext context, String referralCode) {
    final transactionState = context.read<TransactionBloc>().state;

    // Dynamically calculate the deposit count
    int depositCount = 0;
    if (transactionState is TransactionSuccessState) {
      depositCount = transactionState.transactions
          .where((txn) => txn['transaction_type'] == 0)
          .length;
    }

    // Open the dialog with the calculated deposit count
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ReferPage(
          referralCode: referralCode,
          depositCount: depositCount, // Dynamically calculated
        );
      },
    );
  }

  void _showLevelsDialog(
      BuildContext context, List<Map<String, dynamic>> levelCounts) {
    // Map levels to planets and thresholds
    final Map<int, Map<String, dynamic>> levelDetails = {
      1: {"name": "Mercury", "threshold": 100},
      2: {"name": "Venus", "threshold": 500},
      3: {"name": "Earth", "threshold": 2000},
      4: {"name": "Mars", "threshold": 5000},
      5: {"name": "Jupiter", "threshold": 12000},
      6: {"name": "Saturn", "threshold": 25000},
      7: {"name": "Uranus", "threshold": 40000},
      8: {"name": "Neptune", "threshold": 60000},
    };

    // Filter the levels with count > 0
    final List<Map<String, dynamic>> filteredLevels =
        levelCounts.where((level) => level['count'] > 0).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: Container(
              width: 400.w,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary, width: 1),
              ),
              child: Stack(
                children: [
                  // Main content
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      const Text(
                        'Level Counts',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      filteredLevels.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredLevels.length,
                              itemBuilder: (context, index) {
                                final Map<String, dynamic> level =
                                    filteredLevels[index];
                                final int levelNumber = level['level'];
                                final int count = level['count'];
                                final String levelName =
                                    levelDetails[levelNumber]?['name'] ??
                                        "Unknown";
                                final int threshold = levelDetails[levelNumber]
                                        ?['threshold'] ??
                                    0;

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Level $levelNumber',
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '$count',
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          : const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Text(
                                'No levels reached yet.',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                    ],
                  ),

                  // Close button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _addWalletDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: Container(
              width: 400.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary, width: 1),
                color: Colors.black,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Set Wallet Address',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        const SizedBox(height: 24),
                        GradientOutlinedButton(
                          onPressed: () {
                            
                          },
                          text: 'Update',
                          gradientColors: const [
                            Color(0xFFFF3BFF),
                            Color(0xFFECBFBF),
                            Color(0xFF5C24FF),
                            Color(0xFFD94FD5),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

