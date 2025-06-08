import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inddigipay/bloc/walletcreateBloc/walletcreate_bloc.dart';
import 'package:inddigipay/config.dart';
import 'package:inddigipay/repo/walletcreate.dart';
import 'dart:convert';
import 'package:inddigipay/bloc/walletbalanceBloc/walletbalance_bloc.dart';

class Wallet {
  final String name;
  final String address;
  final String imagePath;

  Wallet({required this.name, required this.address, required this.imagePath});
}

class WalletsPage extends StatefulWidget {
  const WalletsPage({super.key});

  @override
  State<WalletsPage> createState() => _WalletsPageState();
}

class _WalletsPageState extends State<WalletsPage> {
  final List<Wallet> wallets = [];
  int selectedIndex = 0;
  final _secureStorage = const FlutterSecureStorage();
  late final WalletCreateRepo _walletRepo;  @override
  void initState() {
    super.initState();
    _walletRepo = WalletCreateRepo();
    // Only call _loadSelectedWallet since it internally calls _loadSavedWallet
    _loadSelectedWallet();
  }
  Future<void> _loadSavedWallet() async {
    final walletsJson = await _secureStorage.read(key: 'wallets') ?? '[]';
    final walletsList = List<Map<String, dynamic>>.from(
      jsonDecode(walletsJson)
    );

    setState(() {
      wallets.clear();
      for (final wallet in walletsList) {
        wallets.add(Wallet(
          name: wallet['name'] as String,
          address: wallet['address'] as String,
          imagePath: AppImages.logo,
        ));
      }
    });
  }  Future<void> _selectWallet(int index) async {
    if (index < 0 || index >= wallets.length) return;
    
    setState(() {
      selectedIndex = index;
    });
    
    final selectedWallet = wallets[index];
    
    // Store current wallet name and address
    await _secureStorage.write(key: 'currentName', value: selectedWallet.name);
    await _secureStorage.write(key: 'currentAddress', value: selectedWallet.address);
    
    // Get wallet data and save full wallet data
    final walletsJson = await _secureStorage.read(key: 'wallets') ?? '[]';
    final walletsList = List<Map<String, dynamic>>.from(jsonDecode(walletsJson));
    
    // Find and save full wallet data
    final fullWalletData = walletsList.firstWhere(
      (w) => w['address'] == selectedWallet.address,
      orElse: () => {
        'name': selectedWallet.name,
        'address': selectedWallet.address,
      }
    );
    
    await _secureStorage.write(
      key: 'selected_wallet',
      value: jsonEncode(fullWalletData),
    );

    // Explicitly trigger balance update and wait a moment for it to start
    if (mounted) {
      context.read<WalletbalanceBloc>().add(
        FetchBalanceEvent(address: selectedWallet.address)
      );
      // Small delay to ensure the balance update has started
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (mounted && Navigator.canPop(context)) {
      // Return true to indicate a wallet was selected
      Navigator.pop(context, true);
    }
  }

  void _createWallet() {
    context.read<WalletcreateBloc>().add(const FetchWalletCreate());
  }  Future<void> _saveWalletCredentials(String mnemonic, String privateKey, String address) async {
    // First, get the list of existing wallets
    final walletsJson = await _secureStorage.read(key: 'wallets') ?? '[]';
    List<Map<String, dynamic>> walletsList = List<Map<String, dynamic>>.from(
      jsonDecode(walletsJson)
    );

    // Generate wallet name
    final walletName = 'Wallet ${walletsList.length + 1}';
    
    // Create new wallet data
    final newWallet = {
      'name': walletName,
      'mnemonic': mnemonic,
      'private_key': privateKey,
      'address': address,
    };
    
    // Add to list and save
    walletsList.add(newWallet);
    await _secureStorage.write(
      key: 'wallets',
      value: jsonEncode(walletsList),
    );
    
    // Set as current wallet
    await _secureStorage.write(key: 'currentName', value: walletName);
    await _secureStorage.write(key: 'currentAddress', value: address);
  }
  Future<void> _saveImportedWallet(String address) async {
    final walletsJson = await _secureStorage.read(key: 'wallets') ?? '[]';
    List<Map<String, dynamic>> walletsList = List<Map<String, dynamic>>.from(
      jsonDecode(walletsJson)
    );

    final walletName = 'Imported Wallet ${walletsList.length + 1}';
    
    // Create new wallet data
    final newWallet = {
      'name': walletName,
      'address': address,
    };
    
    // Add to list and save
    walletsList.add(newWallet);
    await _secureStorage.write(
      key: 'wallets',
      value: jsonEncode(walletsList),
    );
    
    // Set as current wallet
    await _secureStorage.write(key: 'currentName', value: walletName);
    await _secureStorage.write(key: 'currentAddress', value: address);
    
    await _loadSavedWallet();
  }  Future<void> _loadSelectedWallet() async {
    await _loadSavedWallet(); // Make sure wallets are loaded first
    
    final selectedWalletJson = await _secureStorage.read(key: 'selected_wallet');
    if (selectedWalletJson != null) {
      final selectedWallet = jsonDecode(selectedWalletJson);
      final selectedIndex = wallets.indexWhere(
        (w) => w.address == selectedWallet['address']
      );
      
      if (selectedIndex != -1 && mounted) {
        setState(() {
          this.selectedIndex = selectedIndex;
        });
      }
    }
  }

  void _showWalletOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Choose Wallet Option',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 45),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _createWallet();
                },
                child: const Text('Create New Wallet'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 45),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _showImportWalletDialog();
                },
                child: const Text('Add Existing Wallet via Private Key'),
              ),
                            const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 45),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _showImportMnemonicWalletDialog();
                },
                child: const Text('Add Existing Wallet via Mnemonic'),
              ),

            ],
          ),
        );
      },
    );
  }

  void _showImportWalletDialog() {
    final TextEditingController passphraseController = TextEditingController();
    bool isLoading = false;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: const Text(
                'Import Wallet',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: passphraseController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Enter your privatekey',
                      hintStyle: TextStyle(color: Colors.grey),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (passphraseController.text.isNotEmpty) {
                            setState(() {
                              isLoading = true;
                            });

                            try {
                              final result = await _walletRepo.fetchExistingWallet(passphraseController.text);
                                if (result['status'] == 'success') {
                                final address = result['address'];
                                await _saveImportedWallet(address);
                                
                                // Select the imported wallet
                                final newIndex = wallets.indexWhere((w) => w.address == address);
                                if (newIndex != -1) {
                                  await _selectWallet(newIndex);
                                }
                                
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Wallet imported successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to import wallet: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              setState(() {
                                isLoading = false;
                              });
                            }
                          }
                        },
                  child: const Text('Import'),
                ),
              ],
            );
          }
        );
      },
    );
  }
  void _showImportMnemonicWalletDialog() {
    final TextEditingController mnemonicController = TextEditingController();
    bool isLoading = false;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: const Text(
                'Import Wallet',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: mnemonicController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Enter your mnemonic',
                      hintStyle: TextStyle(color: Colors.grey),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (mnemonicController.text.isNotEmpty) {
                            setState(() {
                              isLoading = true;
                            });

                            try {                              final result = await _walletRepo.fetchByMnemonic(mnemonicController.text);
                                if (result['status'] == 'success') {
                                final address = result['address'];
                                await _saveImportedWallet(address);
                                
                                // Select the imported wallet
                                final newIndex = wallets.indexWhere((w) => w.address == address);
                                if (newIndex != -1) {
                                  await _selectWallet(newIndex);
                                }
                                
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Wallet imported successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to import wallet: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              setState(() {
                                isLoading = false;
                              });
                            }
                          }
                        },
                  child: const Text('Import'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  Future<void> _showWalletDetailsDialog(Wallet wallet) async {
    // Get wallet data from secure storage
    final walletsJson = await _secureStorage.read(key: 'wallets') ?? '[]';
    final walletsList = List<Map<String, dynamic>>.from(jsonDecode(walletsJson));
    
    // Find the full wallet data including mnemonic and private key
    final walletData = walletsList.firstWhere(
      (w) => w['address'] == wallet.address,
      orElse: () => {
        'name': wallet.name,
        'address': wallet.address,
      }
    );

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    wallet.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailSection(
                context,
                'Wallet Address',
                wallet.address,
              ),
              if (walletData['private_key'] != null) ...[
                const SizedBox(height: 16),
                _buildDetailSection(
                  context,
                  'Private Key',
                  walletData['private_key'],
                ),
              ],
              if (walletData['mnemonic'] != null) ...[
                const SizedBox(height: 16),
                _buildDetailSection(
                  context,
                  'Recovery Phrase',
                  walletData['mnemonic'],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Never share your recovery phrase or private key with anyone.',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(BuildContext context, String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF282828),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, color: Colors.grey, size: 20),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$title copied to clipboard')),
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WalletcreateBloc, WalletcreateState>(
      listener: (context, state) async {
        if (state is WalletcreateLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          );
        } else if (state is WalletcreateLoaded) {
          // Dismiss loading indicator if showing
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          
          final walletData = state.data.first;
          final address = walletData['address'] as String;
          final mnemonic = walletData['mnemonic'] as String;
          final privateKey = walletData['private_key'] as String;          // Save credentials securely
          await _saveWalletCredentials(mnemonic, privateKey, address);
          
          // Refresh the wallets list from storage
          await _loadSavedWallet();
          
          // Select the newly created wallet
          final newIndex = wallets.indexWhere((w) => w.address == address);
          if (newIndex != -1) {
            await _selectWallet(newIndex);
          }
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Wallet created successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is WalletcreateError) {
          // Dismiss loading indicator if showing
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create wallet: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFF121212),
          appBar: AppBar(
            backgroundColor: const Color(0xFF121212),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Wallets',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Multi-coin wallets',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: wallets.length,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemBuilder: (context, index) {
                    final wallet = wallets[index];
                    final isSelected = selectedIndex == index;                    return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF1E1E1E) : const Color(0xFF181818),
                          borderRadius: BorderRadius.circular(12),
                        ),child: ListTile( 
                          onTap: () => _selectWallet(index),
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.white,
                                backgroundImage: AssetImage(wallet.imagePath),
                              ),
                              if (isSelected)
                                const Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Icon(
                                    Icons.check_circle,
                                    size: 14,
                                    color: Colors.green,
                                  ),
                                ),
                            ],
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  wallet.name,
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ),
                              TextButton(
                                onPressed: () => _showWalletDetailsDialog(wallet),
                                style: TextButton.styleFrom(
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  minimumSize: Size.zero,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.remove_red_eye,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Details',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            wallet.address,
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                          onLongPress: () {
                            // Show wallet details dialog on long press
                            _showWalletDetailsDialog(wallet);
                          },
                        ),
                      
                    );
                  },
                ),
              ),
            ],
          ),          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _showWalletOptionsDialog,
              child: const Text(
                'Wallet Options',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        );
      },
    );
  }
}
