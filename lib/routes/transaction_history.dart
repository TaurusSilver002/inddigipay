import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inddigipay/bloc/transHistoryBloc/trans_history_bloc.dart';
import 'package:inddigipay/config.dart';

class TransactionHistory extends StatefulWidget {
  final String walletAddress;

  const TransactionHistory({Key? key, required this.walletAddress})
      : super(key: key);

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransHistoryBloc>().add(
            FetchTransHistory(
              address: widget.walletAddress,
              page: 1,
              offset: 20,
            ),
          );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final state = context.read<TransHistoryBloc>().state;
      if (state is TransHistoryLoaded &&
          !_isLoadingMore &&
          state.hasMoreData) {
        setState(() => _isLoadingMore = true);
        context.read<TransHistoryBloc>().add(
              LoadMoreTransHistory(
                address: widget.walletAddress,
                currentPage: state.currentPage,
              ),
            );
      }
    }
  }

  void _showTransactionDetails(Map<String, dynamic> transaction) {
    // final int? fromType = transaction['from_type'] is int
    //     ? transaction['from_type']
    //     : int.tryParse(transaction['from_type']?.toString() ?? '');
    final int? txType = transaction['transaction_type'] is int
        ? transaction['transaction_type']
        : int.tryParse(transaction['transaction_type']?.toString() ?? '');
    final String currency = 'USDT';
    //  fromType == 0 ? 'IDC' : 'USDT';
    final String transactionType = txType == 0
        ? 'Deposit'
        : txType == 1
            ? 'Withdrawal'
            : 'Unknown';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transaction Details',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Type', transactionType),
              _buildDetailRow(
                'Amount',
                '${transaction['amount'] ?? '0'} $currency',
              ),
              _buildDetailRow(
                'Status',
                _getStatusText(transaction['status']),
              ),
              _buildDetailRow(
                'Token Name',
                transaction['tokenName'] ?? 'Unknown',
              ),
              if (transaction['hash'] != null)
                _buildDetailRow('Tx Hash', transaction['hash']),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Close',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              Fluttertoast.showToast(msg: "Copied to clipboard");
            },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.copy,
                  color: AppColors.primary,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(dynamic status) {
    final int? s =
        status is int ? status : int.tryParse(status?.toString() ?? '');
    switch (s) {
      case 1:
        return 'Completed';
      case 0:
        return 'Pending';
      case -1:
        return 'Failed';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(dynamic status) {
    final int? s =
        status is int ? status : int.tryParse(status?.toString() ?? '');
    switch (s) {
      case 1:
        return Colors.green;
      case 0:
        return Colors.orange;
      case -1:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'Transaction History',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<TransHistoryBloc, TransHistoryState>(
        listener: (context, state) {
          if (state is TransHistoryLoaded) {
            setState(() => _isLoadingMore = false);
          }
        },
        builder: (context, state) {
          if (state is TransHistoryLoading && !_isLoadingMore) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TransHistoryError) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          if (state is TransHistoryLoaded) {
            return ListView.builder(
              controller: _scrollController,
              itemCount: state.transactions.length + (_isLoadingMore ? 1 : 0),
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                if (index == state.transactions.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final transaction = state.transactions[index];

                // final int? fromType = transaction['from_type'] is int
                //     ? transaction['from_type']
                //     : int.tryParse(transaction['from_type']?.toString() ?? '');
                final int? txType = transaction['transaction_type'] is int
                    ? transaction['transaction_type']
                    : int.tryParse(transaction['transaction_type']?.toString() ?? '');

                final String currency = 'USDT';
                // fromType == 0 ? 'IDC' : 'USDT';
                final String transactionType = txType == 0
                    ? 'Deposit'
                    : txType == 1
                        ? 'Withdrawal'
                        : 'Unknown';

                return Card(
                  color: AppColors.cardBackground,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          transactionType,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12
                          ),
                        ),
                        Text(
                          '${transaction['amount'] ?? '0'} $currency',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                             fontSize: 12

                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      'Status: ${_getStatusText(transaction['status'])}',
                      style: TextStyle(
                        color: _getStatusColor(transaction['status']),
                        fontSize: 10,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                      ),
                      onPressed: () => _showTransactionDetails(transaction),
                    ),
                  ),
                );
              },
            );
          }

          return const Center(
            child: Text(
              'No transactions found',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        },
      ),
    );
  }
}
