import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inddigipay/bloc/wthdrawBloc/withdraw_bloc.dart';
import 'package:inddigipay/components/depositbutton.dart';
import 'package:inddigipay/components/gradientoutlinedbutton.dart';
import 'package:inddigipay/config.dart';


class WithdrawlWeb extends StatefulWidget {
  final String walletAddress;
  final String referralBalance; 

  const WithdrawlWeb({
    Key? key,
    required this.walletAddress,
    required this.referralBalance,
  }) : super(key: key);

  @override
  _WithdrawlWebState createState() => _WithdrawlWebState();
}

class _WithdrawlWebState extends State<WithdrawlWeb> {
  int? selectedAmount;

  void _onAmountSelected(int amount) {
    setState(() {
      selectedAmount = amount; 
    });
  }

  void _onWithdrawButtonPressed(BuildContext context) {
    if (selectedAmount != null) {
      context.read<WithdrawBloc>().add(WithdrawRequestEvent(amount: selectedAmount!));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an amount to withdraw.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double currentBalance = double.tryParse(widget.referralBalance) ?? 0;

    return BlocListener<WithdrawBloc, WithdrawState>(
      listener: (context, state) {
        if (state is WithdrawLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Processing your withdrawal...'),
              duration: Duration(seconds: 1),
            ),
          );
        } else if (state is WithdrawSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Withdrawal successful: ${state.responseData['message'] ?? ''}'),
              duration: Duration(seconds: 2),
            ),
          );
        } else if (state is WithdrawFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Withdrawal failed: ${state.error}'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(16.sp),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary, width: 1),
          color: Colors.black,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
                        Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
                onPressed: () {
                  Navigator.of(context).pop(); 
                },
              ),
            ),

            Text(
              'Personal Wallet Address',
              style: TextStyle(color: Colors.white, fontSize: 20.sp),
            ),
            SizedBox(height: 20.sp),
            SizedBox(
              width: double.infinity,
              child: TextFormField(
                initialValue: widget.walletAddress,
                readOnly: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(255, 36, 36, 36),
                  contentPadding: EdgeInsets.symmetric(vertical: 10.sp, horizontal: 12.sp),
                  hintStyle: const TextStyle(color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: widget.walletAddress));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied to clipboard!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.copy,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                  ),
                ),
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
            SizedBox(height: 20.sp),
              Text(
              'Referral Balance: ${widget.referralBalance} USDT',
              style: TextStyle(color: AppColors.primary, fontSize: 16.sp),
            ),             SizedBox(height: 20.sp),

            const Text(
              'Select a value to withdraw.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.sp),
            Wrap(
              spacing: 8.sp,
              runSpacing: 12.sp,
              alignment: WrapAlignment.center,
              children: [
                for (var amount in [10,50, 75, 100, 150, 200, 250, 300, 350, 400, 450, 500])
                  DepositButton(
                    text: '$amount',
                    onPressed: () => _onAmountSelected(amount),
                    isSelected: selectedAmount == amount, 
                  ),
              ],
            ),
            SizedBox(height: 28.sp),
            currentBalance > 10
                ? GradientOutlinedButton(
                    onPressed: () => _onWithdrawButtonPressed(context),
                    text: 'Withdraw',
                    fillColor: Colors.black,
                    gradientColors: const [
                      Color(0xFFFF3BFF),
                      Color(0xFFECBFBF),
                      Color(0xFF5C24FF),
                      Color(0xFFD94FD5),
                    ],
                  )
                : const Text(
                    '*Insufficient balance. \n Your account balance must exceed 10 USDT to proceed with a withdrawal. ',
                    style: TextStyle(color: Colors.red, fontSize: 12),textAlign: TextAlign.center,
                  ),
          ],
        ),
      ),
    );
  }
}

class AddWalletWeb extends StatelessWidget {
  const AddWalletWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary, width: 1),
        ),
        padding: EdgeInsets.all(16.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.close, color: AppColors.primary),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            const Text(
              'Set Wallet Address',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(height: 20.sp),
            const Text(
              "You have not set a wallet address. Click on 'UPDATE' button to set your wallet address.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            SizedBox(height: 30.sp),
            GradientOutlinedButton(
              onPressed: () {
              },
              text: 'Update',
              fillColor: Colors.black,
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
    );
  }
}
