// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:inddigipay/bloc/userBloc/user_bloc.dart';
// import 'package:inddigipay/bloc/walletsendBloc/walletsend_bloc.dart';
// import 'package:inddigipay/bloc/walletbalanceBloc/walletbalance_bloc.dart';
// import 'package:inddigipay/components/customnav.dart';
// import 'package:inddigipay/config.dart';
// import 'package:inddigipay/repo/walletsend.dart';
// import 'package:inddigipay/repo/walletbalance.dart';
// import 'package:inddigipay/routes/wallets.dart';
// import 'package:inddigipay/services/locater.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:qr_flutter/qr_flutter.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _currentIndex = 0;
//   String selectedWalletName = 'Main Wallet';
//   final _secureStorage = const FlutterSecureStorage();
//   late final WalletbalanceBloc _walletBalanceBloc;

//   @override
//   void initState() {
//     super.initState();
//     _loadWalletName();
//     _walletBalanceBloc = WalletbalanceBloc(locator<WalletBalanceRepo>());
//     _initializeWalletBalance();
//   }

//   @override
//   void dispose() {
//     _walletBalanceBloc.close();
//     super.dispose();
//   }

//   Future<void> _loadWalletName() async {
//     final savedName = await _secureStorage.read(key: 'wallet_name');
//     if (savedName != null) {
//       setState(() {
//         selectedWalletName = savedName;
//       });
//     }
//   }

//   Future<void> _initializeWalletBalance() async {
//     final address = await _secureStorage.read(key: 'wallet_address');
//     if (address != null && mounted) {
//       _walletBalanceBloc.add(FetchBalanceEvent(address: address));
//     }
//   }

//   void _onNavTap(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//   }

//   Future<void> _openWalletsPage() async {
//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const WalletsPage(),
//       ),
//     );
//     await _loadWalletName();
//   }

//   @override
//   Widget build(BuildContext context) {    
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(create: (_) => UserBloc()..add(FetchUserEvent())),
//         BlocProvider.value(value: _walletBalanceBloc),
//       ],
//       child: Scaffold(
//         backgroundColor: AppColors.background,
//         appBar: AppBar(
//           backgroundColor: AppColors.background,
//           elevation: 0,
//           leadingWidth: 96,
//           leading: Row(
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.work_history, color: AppColors.textPrimary),
//                 onPressed: () {},
//               ),
//               IconButton(
//                 icon: const Icon(Icons.qr_code, color: AppColors.textPrimary),
//                 onPressed: () {
//                   showDialog(
//             context: context,
//             builder: (context) => const ReceiveDialog(),
//           );
//                 },
//               ),
//             ],
//           ),
//           title: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 selectedWalletName,
//                 style: const TextStyle(
//                   color: AppColors.textPrimary,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(width: 4),
//               GestureDetector(
//                 onTap: _openWalletsPage,
//                 child: Stack(
//                   alignment: Alignment.topRight,
//                   children: [
//                     const Icon(Icons.arrow_drop_down, color: AppColors.textPrimary),
//                     Positioned(
//                       right: 0,
//                       top: 2,
//                       child: Container(
//                         width: 6,
//                         height: 6,
//                         decoration: const BoxDecoration(
//                           color: Colors.red,
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           centerTitle: true,
          
//         ),
//         body: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: BlocBuilder<WalletbalanceBloc, WalletbalanceState>(
//                   builder: (context, state) {
//                     if (state is WalletbalanceLoading) {
//                       return const CircularProgressIndicator();
//                     } else if (state is WalletbalanceLoaded) {
//                       return Text(
//                         '\$${state.balance.toStringAsFixed(2)}',
//                         style: const TextStyle(
//                           color: AppColors.textPrimary,
//                           fontSize: 32,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       );
//                     } else if (state is WalletbalanceError) {
//                       // Show error in SnackBar
//                       WidgetsBinding.instance.addPostFrameCallback((_) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text(state.message),
//                             backgroundColor: Colors.red,
//                           ),
//                         );
//                       });
//                       // Show simple error text in UI
//                       return const Text(
//                         'Balance: Error',
//                         style: TextStyle(
//                           color: Colors.red,
//                           fontSize: 16,
//                         ),
//                       );
//                     }
//                     return const Text(
//                       '\$0.00',
//                       style: TextStyle(
//                         color: AppColors.textPrimary,
//                         fontSize: 32,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               Center(
//                 child: BlocBuilder<WalletbalanceBloc, WalletbalanceState>(
//                   builder: (context, state) {
//                     if (state is WalletbalanceLoaded) {
//                       return const Text(
//                         '0%',
//                         style: TextStyle(
//                           color: AppColors.textSecondary,
//                           fontSize: 16,
//                         ),
//                       );
//                     }
//                     return const SizedBox.shrink(); // Hide when no balance
//                   },
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _buildActionButton(Icons.arrow_upward, 'Send'),
//                   _buildActionButton(Icons.arrow_downward, 'Receive'),
//                 ],
//               ),
//               const SizedBox(height: 24),
//               const Text(
//                 'Crypto',
//                 style: TextStyle(
//                   color: AppColors.textPrimary,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               const Center(
//                 child: Text(
//                   'Your wallet is empty.',
//                   style: TextStyle(
//                     color: AppColors.textSecondary,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               SizedBox(
//                 width: double.infinity,
//                 child: OutlinedButton(
//                   onPressed: () {},
//                   style: OutlinedButton.styleFrom(
//                     side: const BorderSide(color: AppColors.textSecondary),
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(24),
//                     ),
//                   ),
//                   child: const Text(
//                     'Buy Crypto',
//                     style: TextStyle(
//                       color: AppColors.textPrimary,
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {},
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(24),
//                     ),
//                   ),
//                   child: const Text(
//                     'Buy IDC',
//                     style: TextStyle(
//                       color: AppColors.textPrimary,
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               SizedBox(
//                 width: double.infinity,
//                 child: OutlinedButton(
//                   onPressed: () {},
//                   style: OutlinedButton.styleFrom(
//                     side: const BorderSide(color: AppColors.textSecondary),
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(24),
//                     ),
//                   ),
//                   child: const Text(
//                     'Deposit Crypto',
//                     style: TextStyle(
//                       color: AppColors.textPrimary,
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Center(
//                 child: TextButton(
//                   onPressed: () {},
//                   child: const Text(
//                     'Manage crypto',
//                     style: TextStyle(
//                       color: AppColors.primary,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         bottomNavigationBar: CustomBottomNavBar(
//           currentIndex: _currentIndex,
//           onTap: _onNavTap,
//         ),
//       ),
//     );
//   }

//   Widget _buildActionButton(IconData icon, String label) {
//     return GestureDetector(
//       onTap: () {
//         if (label == 'Send') {
//           showDialog(
//             context: context,
//             builder: (context) => BlocProvider(
//               create: (context) => WalletsendBloc(locator<WalletSendRepo>()),
//               child: SendDialog(walletBalanceBloc: _walletBalanceBloc),
//             ),
//           );
//         } else if (label == 'Receive') {
//           showDialog(
//             context: context,
//             builder: (context) => const ReceiveDialog(),
//           );
//         }
//       },
//       child: Column(
//         children: [
//           Container(
//             width: 48,
//             height: 48,
//             decoration: BoxDecoration(
//               color: label == 'Buy' ? AppColors.primary : AppColors.cardBackground,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Center(
//               child: Icon(icon, color: AppColors.textPrimary),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             label,
//             style: const TextStyle(
//               color: AppColors.textPrimary,
//               fontSize: 12,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class SendDialog extends StatefulWidget {
//   final WalletbalanceBloc walletBalanceBloc;
  
//   const SendDialog({
//     Key? key, 
//     required this.walletBalanceBloc,
//   }) : super(key: key);

//   @override
//   _SendDialogState createState() => _SendDialogState();
// }

// class _SendDialogState extends State<SendDialog> {
//   final _recipientController = TextEditingController();
//   final _amountController = TextEditingController();
//   final _secureStorage = const FlutterSecureStorage();

//   @override
//   void dispose() {
//     _recipientController.dispose();
//     _amountController.dispose();
//     super.dispose();
//   }

//   Future<void> _handleSend(BuildContext context) async {
//     final recipient = _recipientController.text.trim();
//     final amountText = _amountController.text.trim();

//     if (recipient.isEmpty || amountText.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please fill in all fields'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     final amount = double.tryParse(amountText);
//     if (amount == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter a valid amount'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     final passPhrase = await _secureStorage.read(key: 'wallet_mnemonic');
//     if (passPhrase == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Wallet not found'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     if (!mounted) return;

//     context.read<WalletsendBloc>().add(
//       SendTransactionEvent(
//         passPhrase: passPhrase,
//         to: recipient,
//         amount: amount,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.transparent,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: AppColors.background,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: AppColors.primary),
//         ),
//         child: BlocListener<WalletsendBloc, WalletsendState>(
//           listener: (context, state) async {
//             if (state is WalletsendSuccess) {
//               // Show success animation
//               showDialog(
//                 context: context,
//                 barrierDismissible: false,
//                 builder: (BuildContext context) {
//                   return Dialog(
//                     backgroundColor: Colors.transparent,
//                     child: const Center(
//                       child: Icon(
//                         Icons.check_circle,
//                         color: AppColors.primary,
//                         size: 60,
//                       ),
//                     ),
//                   );
//                 },
//               );

//               // Wait for 1 second
//               await Future.delayed(const Duration(seconds: 1));

//               // Get stored wallet address
//               final address = await _secureStorage.read(key: 'wallet_address');

//               // Close both dialogs and show success message
//               if (!mounted) return;
//               Navigator.of(context).pop(); // Close success animation
//               Navigator.of(context).pop(); // Close send dialog
              
//               // Refresh wallet balance if we have the address
//               if (address != null) {
//                 widget.walletBalanceBloc.add(FetchBalanceEvent(address: address));
//               }
              
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text(state.message),
//                   backgroundColor: Colors.green,
//                 ),
//               );
//             } else if (state is WalletsendFailure) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text(state.message),
//                   backgroundColor: Colors.red,
//                 ),
//               );
//             }
//           },
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const Text(
//                 'Send Crypto',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: _recipientController,
//                 style: const TextStyle(color: Colors.white),
//                 decoration: const InputDecoration(
//                   hintText: 'Recipient Address',
//                   hintStyle: TextStyle(color: Colors.grey),
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: AppColors.primary),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: AppColors.primary),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: _amountController,
//                 style: const TextStyle(color: Colors.white),
//                 keyboardType: TextInputType.numberWithOptions(decimal: true),
//                 decoration: const InputDecoration(
//                   hintText: 'Amount',
//                   hintStyle: TextStyle(color: Colors.grey),
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: AppColors.primary),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: AppColors.primary),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               BlocBuilder<WalletsendBloc, WalletsendState>(
//                 builder: (context, state) {
//                   return ElevatedButton(
//                     onPressed: state is WalletsendLoading
//                         ? null
//                         : () => _handleSend(context),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primary,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(24),
//                       ),
//                     ),
//                     child: state is WalletsendLoading
//                         ? const SizedBox(
//                             height: 20,
//                             width: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor:
//                                   AlwaysStoppedAnimation<Color>(Colors.white),
//                             ),
//                           )
//                         : const Text(
//                             'Send',
//                             style: TextStyle(color: Colors.white),
//                           ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ReceiveDialog extends StatelessWidget {
//   const ReceiveDialog({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.transparent,
//       child: FutureBuilder<String?>(
//         future: const FlutterSecureStorage().read(key: 'wallet_address'),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final walletAddress = snapshot.data;
//           if (walletAddress == null) {
//             return Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: AppColors.background,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: AppColors.primary),
//               ),
//               child: const Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'No wallet address found',
//                     style: TextStyle(color: Colors.red),
//                   ),
//                 ],
//               ),
//             );
//           }

//           return Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: AppColors.background,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: AppColors.primary),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text(
//                   'Receive Crypto',
//                   style: TextStyle(
//                     color: AppColors.primary,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: QrImageView(
//                     data: walletAddress,
//                     version: QrVersions.auto,
//                     size: 200.0,
//                     backgroundColor: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 GestureDetector(
//                   onTap: () {
//                     Clipboard.setData(ClipboardData(text: walletAddress));
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Address copied to clipboard'),
//                         backgroundColor: Colors.green,
//                       ),
//                     );
//                   },
//                   child: Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: AppColors.cardBackground,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: AppColors.primary),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Flexible(
//                           child: Text(
//                             walletAddress,
//                             style: const TextStyle(color: Colors.white),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         const Icon(
//                           Icons.copy,
//                           color: AppColors.primary,
//                           size: 20,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
