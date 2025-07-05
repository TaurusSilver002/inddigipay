import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inddigipay/bloc/userBloc/user_bloc.dart';
import 'package:inddigipay/bloc/walletbalanceBloc/walletbalance_bloc.dart';
import 'package:inddigipay/bloc/walletsendBloc/walletsend_bloc.dart';
import 'package:inddigipay/bloc/transHistoryBloc/trans_history_bloc.dart';
import 'package:inddigipay/components/customnav.dart';
import 'package:inddigipay/components/qr_scanner.dart';
import 'package:inddigipay/config.dart';
import 'package:inddigipay/repo/walletsend.dart';
import 'package:inddigipay/routes/homepage.dart';
import 'package:inddigipay/routes/profile_redirector.dart';
import 'package:inddigipay/routes/transaction_history.dart';
import 'package:inddigipay/routes/wallets.dart';
import 'package:inddigipay/routes/send_page.dart';
import 'package:inddigipay/routes/receive_page.dart';
import 'package:inddigipay/services/locator.dart';
import 'package:inddigipay/utils/route_transitions.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String selectedWalletName = 'Select Wallet';
  String? selectedWalletAddress;
  final _secureStorage = const FlutterSecureStorage();
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadSelectedWallet();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadSelectedWallet() async {
    final currentName = await _secureStorage.read(key: 'currentName');
    final currentAddress = await _secureStorage.read(key: 'currentAddress');

    if (currentName != null && currentAddress != null && mounted) {
      setState(() {
        selectedWalletName = currentName;
        selectedWalletAddress = currentAddress;
      });

      if (context.mounted) {
        context.read<WalletbalanceBloc>().add(FetchBalanceEvent(address: currentAddress));
      }
    }
  }

  void _handleTabTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }  void _openSendPage(BuildContext context) {
    if (selectedWalletAddress == null) {
      Fluttertoast.showToast(msg: "Please select a wallet first");
      return;
    }    
    Navigator.push(
      context,
      SlidePageRoute(
        page: BlocProvider(
          create: (context) => WalletsendBloc(locator<WalletSendRepo>()),
          child: SendPage(
            walletAddress: selectedWalletAddress!,
            walletName: selectedWalletName,
            secureStorage: _secureStorage,
            
            onSuccess: _loadSelectedWallet,
          ),
        ),
      ),
    );
  }
  void _openReceivePage(BuildContext context) {
    if (selectedWalletAddress == null) {
      Fluttertoast.showToast(msg: "Please select a wallet first");
      return;
    }    
    Navigator.push(
      context,
      SlidePageRoute(
        page: ReceivePage(
          walletAddress: selectedWalletAddress!,
          walletName: selectedWalletName,
        ),
      ),
    );
  }

  Future<void> _openWalletsPage() async {
    final walletBalanceBloc = context.read<WalletbalanceBloc>();    final result = await Navigator.push<bool>(
      context,
      SlidePageRoute(
        page: BlocProvider<WalletbalanceBloc>.value(
          value: walletBalanceBloc,
          child: const WalletsPage(),
        ),
      ),
    );

    if (result == true) {
      await _loadSelectedWallet();
    }
  }

  Future<bool> _onWillPop() async {
    if (_currentIndex != 0) {
      _handleTabTap(0);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    context.read<UserBloc>().add(const FetchUserEvent());

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _currentIndex == 0
            ? AppBar(
                backgroundColor: AppColors.background,
                elevation: 0,
                leadingWidth: 96,
                leading: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.work_history, color: AppColors.textPrimary),
                      onPressed: () async {
                        if (selectedWalletAddress == null) {
                          Fluttertoast.showToast(msg: "Please select a wallet first");
                          return;
                        }
                    final transHistoryBloc = TransHistoryBloc();
                        await Navigator.push(
                          context,
                          SlidePageRoute(
                            page: BlocProvider(
                              create: (_) => transHistoryBloc,
                              child: TransactionHistory(walletAddress: selectedWalletAddress!),
                            ),
                          ),
                        );
                      },
                    ),                    IconButton(
                      icon: const Icon(Icons.qr_code, color: AppColors.textPrimary),
                      onPressed: () => _openReceivePage(context),
                    ),
                  ],
                ),
                title: GestureDetector(
                  onTap: _openWalletsPage,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedWalletName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: AppColors.textPrimary),
                    ],
                  ),
                ),
                centerTitle: true,
              )
            : null,
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: [            HomePage(
              selectedWalletName: selectedWalletName,
              selectedWalletAddress: selectedWalletAddress,
              onSendTap: () => _openSendPage(context),
              onReceiveTap: () => _openReceivePage(context),
            ),
            const ProfileRedirector(),
          ],
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTap: _handleTabTap,
        ),
      ),
    );
  }
}

class SendDialog extends StatefulWidget {
  final String walletAddress;
  final String walletName;
  final FlutterSecureStorage secureStorage;
  final VoidCallback onSuccess;

  const SendDialog({
    Key? key,
    required this.walletAddress,
    required this.walletName,
    required this.secureStorage,
    required this.onSuccess,
  }) : super(key: key);

  @override
  _SendDialogState createState() => _SendDialogState();
}

class _SendDialogState extends State<SendDialog> {
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _passphraseController = TextEditingController();

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _passphraseController.dispose();
    super.dispose();
  }

  Future<void> _handleSend(BuildContext context) async {
    final recipient = _recipientController.text.trim();
    final amountText = _amountController.text.trim();
    final passPhrase = _passphraseController.text.trim();

    if (recipient.isEmpty || amountText.isEmpty || passPhrase.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please fill in all fields',
        backgroundColor: Colors.red,
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null) {
      Fluttertoast.showToast(
        msg: 'Please enter a valid amount',
        backgroundColor: Colors.red,
      );
      return;
    }

    if (!mounted) return;

    context.read<WalletsendBloc>().add(
          SendTransactionEvent(
            passPhrase: passPhrase,
            to: recipient,
            amount: amount,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary),
        ),
        child: BlocListener<WalletsendBloc, WalletsendState>(
          listener: (context, state) async {
            if (state is WalletsendSuccess) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return Dialog(
                    backgroundColor: Colors.transparent,
                    child: const Center(
                      child: Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 60,
                      ),
                    ),
                  );
                },
              );

              await Future.delayed(const Duration(seconds: 1));

              if (!mounted) return;
              Navigator.of(context).pop();
              Navigator.of(context).pop();

              final currentAddress = await widget.secureStorage.read(key: 'currentAddress');
              if (currentAddress != null) {
                context.read<WalletbalanceBloc>().add(
                      FetchBalanceEvent(address: currentAddress),
                    );
              }

              Fluttertoast.showToast(
                msg: state.message,
                backgroundColor: Colors.green,
              );
            } else if (state is WalletsendFailure) {
              Fluttertoast.showToast(
                msg: state.message,
                backgroundColor: Colors.red,
              );
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Send from ${widget.walletName}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _recipientController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Recipient Address',
                        hintStyle: TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => QRScanner(
                            onScanned: (address) {
                              _recipientController.text = address;
                            },
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.qr_code_scanner,
                        color: Colors.white,
                      ),
                      tooltip: 'Scan QR Code',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passphraseController,
                style: const TextStyle(color: Colors.white),
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Enter Passphrase',
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                style: const TextStyle(color: Colors.white),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: 'Amount',
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              BlocBuilder<WalletsendBloc, WalletsendState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state is WalletsendLoading ? null : () => _handleSend(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: state is WalletsendLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Send',
                            style: TextStyle(color: Colors.white),
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReceiveDialog extends StatelessWidget {
  final String walletAddress;
  final String walletName;

  const ReceiveDialog({
    Key? key,
    required this.walletAddress,
    required this.walletName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Receive',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              walletName,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: QrImageView(
                data: walletAddress,
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: walletAddress));
                Fluttertoast.showToast(
                  msg: "Address copied to clipboard",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.copy,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        walletAddress,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}