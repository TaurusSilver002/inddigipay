import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inddigipay/components/gradientoutlinedbutton.dart';
import 'package:inddigipay/routes/transaction.dart';
import 'package:intl/intl.dart';
import 'package:inddigipay/bloc/transactionbloc/transaction_bloc.dart';
import 'package:inddigipay/config.dart';



class AllTransactionApp extends StatefulWidget {
  const AllTransactionApp({super.key});

  @override
  State<AllTransactionApp> createState() => _AllTransactionAppState();
}

class _AllTransactionAppState extends State<AllTransactionApp> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool isFilterApplied = false;

  // Status and type methods removed as they were only used for CSV
//final FocusNode _datePickerFocus = FocusNode();
Future<void> _showDateRangePicker(BuildContext context) async {
  final pickedRange = await showDateRangePicker(
    context: context,
    initialDateRange: _startDate != null && _endDate != null
        ? DateTimeRange(start: _startDate!, end: _endDate!)
        : null,
    firstDate: DateTime(2000),
    lastDate: DateTime.now(),
    builder: (BuildContext context, Widget? child) {
      return RepaintBoundary( // Prevent unnecessary redraws
        child: Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.black,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.black,
          ),
          child: child!,
        ),
      );
    },
  );

  if (pickedRange != null) {
    setState(() {
      _startDate = pickedRange.start;
      _endDate = pickedRange.end;
      isFilterApplied = false;
    });
  }
}



void _applyDateFilter() {
  if (_startDate != null && _endDate != null) {
    setState(() {
      isFilterApplied = true;
    });

    context.read<TransactionBloc>().add(FetchTransactionEventWithDate(
      page: 1,
      limit: 10,
      startDate: _startDate!,
      endDate: _endDate!,
    ));

    Fluttertoast.showToast(
      msg: "Filter applied successfully!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      webBgColor: "linear-gradient(to right, #6A5ACD, #9370DB)", 
      webPosition: "center", 
      textColor: Colors.white,
      fontSize: 16.0,
    );
  } else {
    Fluttertoast.showToast(
      msg: "Please select both start and end dates.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      webBgColor: "linear-gradient(to right, #CE2029, #FF4500)", 
      webPosition: "center",
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}

  void _clearDateFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
      isFilterApplied = false;
    });

    context
        .read<TransactionBloc>()
        .add(FetchTransactionEvent(page: 1, limit: 10));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0e0e0e),
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 100,
                ),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppImages.background2),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 80.sp),
                    const Text(
                      'Total Transactions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 20.sp),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.sp),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8.sp),
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          spacing: 10.sp,
                          runSpacing: 10.sp,
                          children: [
                            // Date Range Picker Button
                            Flexible(
                              child: ElevatedButton(
                                onPressed: () => _showDateRangePicker(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 10.sp),
                                ),
                                child: Text(
                                  _startDate != null && _endDate != null
                                      ? '${DateFormat('dd MMM yyyy').format(_startDate!)} - ${DateFormat('dd MMM yyyy').format(_endDate!)}'
                                      : 'Select Date Range',
                                  style: const TextStyle(color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            
                            GradientOutlinedButton(
                              onPressed: isFilterApplied
                                  ? _clearDateFilter
                                  : _applyDateFilter,
                              text: isFilterApplied ? 'Clear' : 'Apply',
                              gradientColors: isFilterApplied
                                  ? [
                                      Colors.red,
                                      Colors.redAccent,
                                      Colors.orange,
                                      Colors.red,
                                    ]
                                  : [
                                      Color(0xFFFF3BFF),
                                      Color(0xFFECBFBF),
                                      Color(0xFF5C24FF),
                                      Color(0xFFD94FD5),
                                    ],
                              fillColor: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.sp),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          // Allow the PaginatedTransactions to take the available space
                          // but don't force it to be too large
                          minHeight: MediaQuery.of(context).size.height * 0.6,
                        ),
                        child: PaginatedTransactions(
                          startDate: _startDate,
                          endDate: _endDate,
                        ),
                      ),
                    ),
                    // Padding(
                    //   padding: EdgeInsets.symmetric(horizontal: 60.sp),
                    //   child: PaginatedTransactions(
                    //     startDate: _startDate,
                    //     endDate: _endDate,
                    //   ),
                    // ),
                    SizedBox(height: 20.sp),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



