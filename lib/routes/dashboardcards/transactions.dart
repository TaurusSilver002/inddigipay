import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inddigipay/config.dart';

class TransactionsPage extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;

  const TransactionsPage({Key? key, required this.transactions}) : super(key: key);

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
    bool showAllTransactions = false;
  String getTransactionType(int type) {
    switch (type) {
      case 1:
        return 'Withdrawal';
      case 0:
        return 'Deposit';
      default:
        return 'Unknown';
    }
  }

  Map<String, dynamic> getStatusDetails(int status) {
    switch (status) {
      case 0:
        return {'status': 'Pending', 'color': Colors.orange};
      case 1:
        return {'status': 'Completed', 'color': Colors.green};
      case -1:
        return {'status': 'Failed', 'color': Colors.red};
      default:
        return {'status': 'Unknown', 'color': Colors.grey};
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> displayedTransactions = showAllTransactions
        ? widget.transactions
        : widget.transactions.take(5).toList(); 

    return Container(
      constraints:  BoxConstraints(maxWidth: 1000.sp),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary,
          width: 1.5,
        ),
        color: Colors.black,
      ),
      child: Column(
        children: [
          const Padding(
            padding:  EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transactions',
                  style: TextStyle(
          color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Amount',
                  style: TextStyle(
          color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white),
          
          ListView.builder(
            itemCount: displayedTransactions.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final transaction = displayedTransactions[index];
              final String about = getTransactionType(transaction['transaction_type']);
              final Map<String, dynamic> statusDetails = getStatusDetails(transaction['status']);
final String currency = transaction['from_type'] == 0 ? 'IDC' : 'USDT';
  final String amount = '${transaction['amount']} $currency'; 
              Color rowColor = index.isEven ? Colors.black54 : Colors.black87;

              return Container(
                color: rowColor,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          about,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          statusDetails['status'],
                          style: TextStyle(
                            color: statusDetails['color'],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      amount,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
    
        ],
      ),
    );
  }
}
