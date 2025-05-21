import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inddigipay/bloc/checkBloc/check_bloc.dart';
import 'package:inddigipay/bloc/depositBloc/deposit_bloc.dart';
import 'package:inddigipay/components/depositbutton.dart';
import 'package:inddigipay/components/gradientoutlinedbutton.dart';
import 'package:inddigipay/config.dart';
import 'package:qr_flutter/qr_flutter.dart';


class DepositWeb extends StatefulWidget {
  final String walletAddress;

  const DepositWeb({
    Key? key,
    required this.walletAddress,
  }) : super(key: key);

  @override
  State<DepositWeb> createState() => _DepositWebState();
}

class _DepositWebState extends State<DepositWeb> {
  int? selectedAmount;
  Timer? _countdownTimer;
  Timer? _statusCheckTimer;
  int _remainingSeconds = 5 * 60; // 5 minutes

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  void _startTimers(BuildContext context, int transactionId) {
    // Reset timers if already running
    _countdownTimer?.cancel();
    _statusCheckTimer?.cancel();
    _remainingSeconds = 5 * 60;

    // Countdown timer
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          timer.cancel();
          _statusCheckTimer?.cancel();
        }
      });
    });

    // Periodic status check
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
      context.read<CheckBloc>().add(CheckStatusEvent(transactionId: transactionId));
    });
  }

  String _formatTimer(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => DepositBloc()),
        BlocProvider(create: (context) => CheckBloc()),
      ],
      child: BlocListener<DepositBloc, DepositState>(
        listener: (context, state) {
          if (state is DepositSuccess) {
            Fluttertoast.showToast(
              msg: state.responseData['message'] ?? 'Deposit successful',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.sp,
            );
            // Start timers with transaction ID
            final transactionId = state.responseData['id'] as int?;
            if (transactionId != null) {
              _startTimers(context, transactionId);
            }
          } else if (state is DepositFailure) {
            Fluttertoast.showToast(
              msg: state.error,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.redAccent,
              textColor: Colors.white,
              fontSize: 16.sp,
            );
          }
        },
        child: Scaffold(
          body: Stack(
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 2000),
                color: Colors.black,
                child: BlocBuilder<DepositBloc, DepositState>(
                  builder: (context, depositState) {
                    if (depositState is DepositSuccess) {
                      return BlocBuilder<CheckBloc, CheckState>(
                        builder: (context, checkState) {
                          // Handle timeout
                          if (_remainingSeconds <= 0) {
                            return Center(
                              child: Text(
                                'Transaction timed out. Please try again.',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 16.sp,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }

                          // Handle CheckBloc states
                          if (checkState is CheckSuccess) {
                            if (checkState.status == 1) {
                              _countdownTimer?.cancel();
                              _statusCheckTimer?.cancel();
                              return Center(
                                child: Text(
                                  'Transaction Completed!',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            } else if (checkState.status == -1) {
                              _countdownTimer?.cancel();
                              _statusCheckTimer?.cancel();
                              return Center(
                                child: Text(
                                  'Transaction Failed',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }
                          } else if (checkState is CheckFailure) {
                            return Center(
                              child: Text(
                                checkState.error,
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 16.sp,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }

                          // Default DepositSuccess UI with QR code, message, and timer
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                QrImageView(
                                  data: depositState.responseData['admin_wallet'],
                                  version: QrVersions.auto,
                                  size: 300.sp,
                                  backgroundColor: Colors.white,
                                  padding: EdgeInsets.all(10.sp),
                                ),
                                SizedBox(height: 10.sp),
                                Text(
                                  depositState.responseData['message'] ?? 'Deposit successful',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16.sp,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 10.sp),
                                Text(
                                  'Time remaining: ${_formatTimer(_remainingSeconds)}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 20.sp),
                                Text('*Donot close this window until the transaction is completed',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 16.sp,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    } else if (depositState is DepositFailure) {
                      return Center(
                        child: Text(
                          depositState.error,
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 16.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    // Full UI for DepositInitial and DepositLoading
                    return CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 20.sp),
                              const Text(
                                'Deposit USDT',
                                style: TextStyle(color: Colors.white, fontSize: 20),
                              ),
                              SizedBox(height: 30.sp),
                              Container(
                                padding: EdgeInsets.all(16.sp),
                                child: Center(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 20.sp),
                                      const Text(
                                        'Select the amount you want to deposit',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 20,
                                        ),
                                      ),
                                      SizedBox(height: 20.sp),
                                      Wrap(
                                        spacing: 8.sp,
                                        runSpacing: 12.sp,
                                        alignment: WrapAlignment.center,
                                        children: [
                                          for (var amount in [
                                            25,
                                            50,
                                            75,
                                            100,
                                            150,
                                            200,
                                            250,
                                            300,
                                            350,
                                            400,
                                            450,
                                            500
                                          ])
                                            DepositButton(
                                              text: '$amount',
                                              onPressed: () => _onAmountSelected(amount),
                                              isSelected: selectedAmount == amount,
                                            ),
                                        ],
                                      ),
                                      SizedBox(height: 36.sp),
                                      GradientOutlinedButton(
                                        onPressed: depositState is DepositLoading
                                            ? null
                                            : () => _onDepositButtonPressed(context),
                                        text: depositState is DepositLoading
                                            ? 'Processing...'
                                            : 'Deposit',
                                        gradientColors: const [
                                          Color(0xFFFF3BFF),
                                          Color(0xFFECBFBF),
                                          Color(0xFF5C24FF),
                                          Color(0xFFD94FD5),
                                        ],
                                      ),
                                      SizedBox(height: 20.sp),
                                      Text(
                                        'Note: The minimum deposit amount is 25 USDT and Network is BSC BEP20',
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 16.sp,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 10.sp),
                                      Text(
                                        '*Only choose from the given values when depositing.\nWe are not responsible for any issues if other values are used.\n\nMake deposits exclusively using Trust Wallet.',
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 16.sp,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              // Close button
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(
                    Icons.close,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onAmountSelected(int amount) {
    setState(() {
      selectedAmount = amount;
    });
  }

  void _onDepositButtonPressed(BuildContext context) {
    if (selectedAmount == null) {
      Fluttertoast.showToast(
        msg: 'Please select an amount to deposit.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 16.sp,
      );
    } else if (selectedAmount! < 25) {
      Fluttertoast.showToast(
        msg: 'Minimum deposit is 25 USDT.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 16.sp,
      );
    } else {
      context.read<DepositBloc>().add(DepositRequestEvent(amount: selectedAmount!));
    }
  }
}