import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inddigipay/bloc/walletcreateBloc/walletcreate_bloc.dart';
import 'package:inddigipay/config.dart';

class Wallet {
  final String name;
  final String address;
  final String imagePath;
  final String mnemonic;
  final String privateKey;

  Wallet({
    required this.name,
    required this.address,
    required this.imagePath,
    required this.mnemonic,
    required this.privateKey,
  });
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

  @override
  void initState() {
    super.initState();
    _loadSavedWallets();
  }

  Future<void> _loadSavedWallets() async {
    final walletCount = await _secureStorage.read(key: 'wallet_count') ?? '0';
    final count = int.tryParse(walletCount) ?? 0;

    for (var i = 0; i < count; i++) {
      final prefix = i == 0 ? '' : '_$i';
      final address = await _secureStorage.read(key: 'wallet_address$prefix');
      final name = await _secureStorage.read(key: 'wallet_name$prefix');
      final mnemonic = await _secureStorage.read(key: 'wallet_mnemonic$prefix');
      final privateKey = await _secureStorage.read(key: 'wallet_private_key$prefix');

      if (address != null && name != null && mnemonic != null && privateKey != null) {
        setState(() {
          wallets.add(Wallet(
            name: name,
            address: address,
            imagePath: AppImages.logo,
            mnemonic: mnemonic,
            privateKey: privateKey,
          ));
        });
      }
    }
  }

  void _selectWallet(int index) {
    setState(() {
      selectedIndex = index;
    });
    Navigator.pop(context, wallets[index].name);
  }

  void _createWallet() {
    context.read<WalletcreateBloc>().add(const FetchWalletCreate());
  }

  Future<void> _saveWalletCredentials(String name, String mnemonic, String privateKey, String address) async {
    final walletCount = wallets.length;
    final prefix = walletCount == 0 ? '' : '_$walletCount';
    
    await _secureStorage.write(key: 'wallet_mnemonic$prefix', value: mnemonic);
    await _secureStorage.write(key: 'wallet_private_key$prefix', value: privateKey);
    await _secureStorage.write(key: 'wallet_address$prefix', value: address);
    await _secureStorage.write(key: 'wallet_name$prefix', value: name);
    await _secureStorage.write(key: 'wallet_count', value: (walletCount + 1).toString());
  }

  void _showWalletOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Option',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _createWallet();
                  },
                  child: const Text('Create New Wallet'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cardBackground,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _showAddExistingWalletDialog();
                  },
                  child: const Text('Add Existing Wallet'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddExistingWalletDialog() {
    final TextEditingController phraseController = TextEditingController();
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add Existing Wallet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Wallet Name',
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
                TextField(
                  controller: phraseController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
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
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () {
                    final name = nameController.text.trim();
                    final passPhrase = phraseController.text.trim();
                    if (name.isEmpty || passPhrase.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all fields'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    // TODO: Implement wallet recovery from passphrase
                    // This should:
                    // 1. Recover private key from passphrase
                    // 2. Generate address from private key
                    // 3. Save wallet credentials
                    // 4. Add wallet to list
                    
                    Navigator.pop(context);
                  },
                  child: const Text('Import Wallet'),
                ),
              ],
            ),
          ),
        );
      },
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
          final privateKey = walletData['private_key'] as String;
          final name = 'Wallet ${wallets.length + 1}';

          // Save credentials securely
          await _saveWalletCredentials(name, mnemonic, privateKey, address);

          // Update wallets list
          setState(() {
            wallets.add(Wallet(
              name: name,
              address: address,
              imagePath: AppImages.logo,
              mnemonic: mnemonic,
              privateKey: privateKey,
            ));
          });

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
                    final isSelected = selectedIndex == index;

                    return GestureDetector(
                      onTap: () => _selectWallet(index),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF1E1E1E) : const Color(0xFF181818),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
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
                          title: Text(
                            wallet.name,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          subtitle: Text(
                            wallet.address,
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          bottomNavigationBar: Padding(
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
                'Add Wallet',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        );
      },
    );
  }
}
