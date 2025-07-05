import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'dart:convert';

import 'package:inddigipay/bloc/transactionbloc/transaction_bloc.dart';
import 'package:inddigipay/config.dart';

class PaginatedTransactions extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;

  const PaginatedTransactions({
    Key? key,
    this.startDate,
    this.endDate,
  }) : super(key: key);

  @override
  _PaginatedTransactionsState createState() => _PaginatedTransactionsState();
}

class _PaginatedTransactionsState extends State<PaginatedTransactions> {
  final ScrollController _scrollController = ScrollController();
  int currentPage = 1;
  bool isLoadingMore = false;
  static const int pageLimit = 10;
  List<Map<String, dynamic>> allTransactionData = [];

  @override
  void initState() {
    super.initState();
    _loadInitialTransactions();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !isLoadingMore) {
        _goToNextPage();
      }
    });
  }

  void _loadInitialTransactions() {
    if (widget.startDate != null && widget.endDate != null) {
      context.read<TransactionBloc>().add(FetchTransactionEventWithDate(
            page: 1,
            limit: pageLimit,
            startDate: widget.startDate!,
            endDate: widget.endDate!,
          ));
    } else {
      context.read<TransactionBloc>().add(const FetchTransactionEvent(page: 1, limit: pageLimit));
    }
  }

  void _goToNextPage() {
    setState(() {
      currentPage++;
      isLoadingMore = true;
    });

    if (widget.startDate != null && widget.endDate != null) {
      context.read<TransactionBloc>().add(FetchTransactionEventWithDate(
            page: currentPage,
            limit: pageLimit,
            startDate: widget.startDate!,
            endDate: widget.endDate!,
          ));
    } else {
      context.read<TransactionBloc>().add(FetchTransactionEvent(page: currentPage, limit: pageLimit));
    }
  }

  void _goToPreviousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
        isLoadingMore = true;
      });

      if (widget.startDate != null && widget.endDate != null) {
        context.read<TransactionBloc>().add(FetchTransactionEventWithDate(
              page: currentPage,
              limit: pageLimit,
              startDate: widget.startDate!,
              endDate: widget.endDate!,
            ));
      } else {
        context.read<TransactionBloc>().add(FetchTransactionEvent(page: currentPage, limit: pageLimit));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          constraints: BoxConstraints( maxWidth: 800.sp),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary, width: 1.5),
            color: Colors.black,
          ),
          child: Column(
            children: [
              BlocConsumer<TransactionBloc, TransactionState>(
                listener: (context, state) {
                  if (state is TransactionSuccessState) {
                    allTransactionData = state.transactions;
                    setState(() {
                      isLoadingMore = false;
                    });
                  }
                },
                builder: (context, state) {
                  if (state is TransactionLoadingState && currentPage == 1) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is TransactionFailureState) {
                    return Center(
                      child: Text(
                        'Error: ${state.message}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (state is TransactionSuccessState) {
                    if (state.transactions.isEmpty) {
                      return const Center(
                        child: Text(
                          'No transactions available.',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    return Column(
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
                          controller: _scrollController,
                          shrinkWrap: true,
                          itemCount: state.transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = state.transactions[index];
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
                                        style: TextStyle(color: statusDetails['color']),
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
                      ],
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_left, color: currentPage > 1 ? AppColors.primary : Colors.grey),
                    onPressed: currentPage > 1 ? _goToPreviousPage : null,
                  ),
                  Text(
                    '$currentPage',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_right, color: AppColors.primary),
                    onPressed: _goToNextPage,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

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
}
