
import 'dart:ui';

class AppColors {
  static const Color primary = Color(0xFF6200EE);
  static const background = Color(0xFF121212); // Dark background
  static const cardBackground = Color(0xFF1E1E1E); // Slightly lighter dark for cards
  static const textPrimary = Color(0xFFFFFFFF); // White text
  static const textSecondary = Color(0xFFB0BEC5);
}

class AppImages {
  static const String logo = 'assets/images/logovio.png';
    static const String background1='assets/images/landing1.png';
    static const String background2='assets/images/mining.png';

  static const String google='assets/images/google.png';
  static const String signcardapp='assets/images/appsignfinal.png';

  
}

class AppConfig{
  static const String baseurl='https://api.inddigi.com';
  //authentication
  static const String loginlink='https://api.inddigi.com/user/login';
  static const String signlink='https://api.inddigi.com/user/register';
  static const String forgotpass='https://api.inddigi.com/user/forget-password';
  static const String confirmpass='https://api.inddigi.com/user/reset-password';
  static const String verifyuser='https://api.inddigi.com/user/verify_user';
  static const String query='https://api.inddigi.com/user/conversation';
  static const String google='https://api.inddigi.com/user/auth/google/callback';
  static const String registergoogle='https://api.inddigi.com/user/register/google';  // New dedicated endpoint for Google registration

  //static const String transaction='https://abfa-27-131-208-102.ngrok-free.app/transaction/transactions/view';
  static const String transaction='https://api.inddigi.com/transaction/transactions/view';
  static const String user='https://api.inddigi.com/user/me';
  static const String updateadd='https://api.inddigi.com/user/update/walletid';
  static const String wallet='https://api.inddigi.com/transaction/referral/withdrawal/add';
  static const String deposit='https://api.inddigi.com//transaction/transactions/crypto-deposit';

  //new app wallet 
  static const String walletcreate='https://api.inddigi.com/transaction/wallet/create';
  static const String existingwallet='https://api.inddigi.com/transaction/wallet/get_wallet_by_private_key';
  static const String mnemonic='https://api.inddigi.com/transaction/wallet/get_wallet_by_mnemonic';
  static const String walletsend='https://api.inddigi.com/transaction/wallet/send';
  static const String balance='https://api.inddigi.com/transaction/wallet/balance';

  static const String transactionhistory='https://api.inddigi.com/transaction/wallet/viewTransaction';
}
