import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WalletStorage {
  static const String _key = 'wallet_accounts';

  // 获取所有钱包账户
  static Future<Map<String, dynamic>> getWallets() async {
    final prefs = await SharedPreferences.getInstance();
    final String? walletsJson = prefs.getString(_key);
    if (walletsJson == null) {
      return {};
    }
    return json.decode(walletsJson);
  }

  // 保存所有钱包账户
  static Future<void> saveWallets(Map<String, dynamic> wallets) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(wallets));
  }

  // 添加或更新单个钱包账户
  static Future<void> updateWallet(
      String accountName, Map<String, dynamic> walletData) async {
    final wallets = await getWallets();
    wallets[accountName] = walletData;
    await saveWallets(wallets);
  }

  // 获取单个钱包账户
  static Future<Map<String, dynamic>?> getWallet(String accountName) async {
    final wallets = await getWallets();
    return wallets[accountName];
  }

  // 删除单个钱包账户
  static Future<void> deleteWallet(String accountName) async {
    final wallets = await getWallets();
    wallets.remove(accountName);
    await saveWallets(wallets);
  }

  // 检查钱包是否存在
  static Future<bool> exists(String accountName) async {
    final wallets = await getWallets();
    return wallets.containsKey(accountName);
  }

  static Future<List<String>> getAllKeys() async {
    final wallets = await getWallets();
    return wallets.keys.toList();
  }
}

// 存储钱包数据
// await WalletStorage.updateWallet('Account1', {
//   'evmAddress': evmAddress,
//   'evmPrivateKey': evmPrivateKey,
//   'btcAddress': btcAddress,
//   'btcPrivateKey': btcPrivateKey,
//   'btcWIF': btcWIF,
// });

// // 获取钱包数据
// final wallet = await WalletStorage.getWallet('Account1');
// if (wallet != null) {
//   final evmAddress = wallet['evmAddress'];
//   final btcAddress = wallet['btcAddress'];
//   // ... 使用其他数据
// }

// // 获取所有钱包
// final allWallets = await WalletStorage.getWallets();
// allWallets.forEach((accountName, walletData) {
//   print('Account: $accountName');
//   print('EVM Address: ${walletData['evmAddress']}');
//   // ... 处理其他数据
// });

// // 删除钱包
// await WalletStorage.deleteWallet('Account1');

// // 检查钱包是否存在
// final exists = await WalletStorage.exists('Account1');