import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inddigipay/components/gradientoutlinedbutton.dart';
import 'package:inddigipay/config.dart';

class ReferPage extends StatelessWidget {
  final String referralCode;
  final int depositCount; 

  const ReferPage({
    super.key,
    required this.referralCode,
    required this.depositCount,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400.w,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.close, color: AppColors.primary),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            const SizedBox(height: 16),
            if (depositCount > 0)
              Column(
                children: [
                  const Text(
                    'Your Referral Code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.sp),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.sp, vertical: 10.sp),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              referralCode,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.copy,
                              color: AppColors.primary,
                              size: 20.sp,
                            ),
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: referralCode));
                              Fluttertoast.showToast(
                                msg: 'Referral Code Copied!',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                webBgColor:
                                    "linear-gradient(to right, #5E45CE, #5E45CE)",
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Share this code with your friends and invite them to join!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'You need to make a deposit before you can refer others!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            // Done Button
            GradientOutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              text: 'Done',
              fillColor: Colors.black,
              gradientColors: const [
                Color(0xFFFF3BFF),
                Color(0xFFECBFBF),
                Color(0xFF5C24FF),
                Color(0xFFD94FD5),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
