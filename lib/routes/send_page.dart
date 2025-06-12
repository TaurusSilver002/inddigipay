import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inddigipay/bloc/walletbalanceBloc/walletbalance_bloc.dart';
import 'package:inddigipay/bloc/walletsendBloc/walletsend_bloc.dart';
import 'package:inddigipay/components/qr_scanner.dart';
import 'package:inddigipay/config.dart';

class SendPage extends StatefulWidget {
  final String walletAddress;
  final String walletName;
  final FlutterSecureStorage secureStorage;
  final VoidCallback onSuccess;

  const SendPage({
    Key? key,
    required this.walletAddress,
    required this.walletName,
    required this.secureStorage,
    required this.onSuccess,
  }) : super(key: key);

  @override
  _SendPageState createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Send from ${widget.walletName}',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<WalletsendBloc, WalletsendState>(
        listener: (context, state) async {
          if (state is WalletsendSuccess) {
            Navigator.pop(context);
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              const SizedBox(height: 24),
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
