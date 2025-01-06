import 'dart:typed_data';

import 'package:bip39/bip39.dart' as bip39;
import 'package:hex/hex.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter_bitcoin/flutter_bitcoin.dart' as bitcoin;
import 'package:convert/convert.dart' show hex; // 添加 hex 包

class WalletRestore {
  // 通过助记词恢复钱包
  static Map<String, String> restoreFromMnemonic(String mnemonic,
      {bool isMainnet = false}) {
    try {
      // 验证助记词
      if (!bip39.validateMnemonic(mnemonic)) {
        throw Exception('无效的助记词');
      }

      // 生成 seed
      final seed = bip39.mnemonicToSeed(mnemonic);

      // 恢复 EVM 钱包
      final privateKey = keccak256(seed);
      var credentials = EthPrivateKey(privateKey);
      final evmAddress = credentials.address.toString();
      final privateKeyHex = bytesToHex(credentials.privateKey, include0x: true);

      // 恢复 BTC 钱包
      final network = isMainnet ? bitcoin.bitcoin : bitcoin.testnet;

      // 从 seed 生成 BTC 私钥
      final btcKey =
          bitcoin.ECPair.fromPrivateKey(privateKey, network: network);

      // 生成 BTC 地址
      final btcPubKey = btcKey.publicKey;
      final btcPayment = bitcoin.P2PKH(
        data: bitcoin.PaymentData(pubkey: btcPubKey),
        network: network,
      );
      final btcAddress = btcPayment.data.address;
      final privateBTCKeyHex = hex.encode(btcKey.privateKey);

      print('\n恢复的钱包信息:');
      print('助记词: $mnemonic');
      print('EVM 地址: $evmAddress');
      print('EVM 私钥: $privateKeyHex');
      print('BTC 地址: $btcAddress');
      print('BTC 私钥: $privateBTCKeyHex');
      print('BTC WIF: ${btcKey.toWIF()}');

      return {
        'mnemonic': mnemonic,
        'evmAddress': evmAddress,
        'evmPrivateKey': privateKeyHex,
        'btcAddress': btcAddress ?? "",
        "btcPrivateKey": privateBTCKeyHex,
        'btcWif': btcKey.toWIF(),
      };
    } catch (e) {
      print('恢复钱包失败: $e');
      return {};
    }
  }

  // 通过私钥恢复钱包
  static Map<String, String> restoreFromPrivateKeyETH(
    String? evmPrivateKey,
  ) {
    try {
      Map<String, String> result = {};

      // 恢复 EVM 钱包
      if (evmPrivateKey != null) {
        final credentials = EthPrivateKey.fromHex(evmPrivateKey);
        result['evmAddress'] = credentials.address.toString();
        result['evmPrivateKey'] = evmPrivateKey;

        // result['evmMnemonic'] = bip39.entropyToMnemonic(evmPrivateKey);
      }

      return result;
    } catch (e) {
      print('恢复钱包失败: $e');
      return {};
    }
  }

  static Map<String, String> restoreFromPrivateKeyBTC(
      String? btcPrivateKey, String? btcWif, bool isMainnet) {
    try {
      Map<String, String> result = {};

      // 恢复 BTC 钱包
      if (btcPrivateKey != null || btcWif != null) {
        final network = isMainnet ? bitcoin.bitcoin : bitcoin.testnet;
        final btcKey = btcWif != null
            ? bitcoin.ECPair.fromWIF(btcWif, network: network)
            : bitcoin.ECPair.fromPrivateKey(
                Uint8List.fromList(
                    hex.decode(btcPrivateKey!)), // 使用 Uint8List.fromList
                network: network);

        // result['btcMnemonic'] = bip39.entropyToMnemonic(btcPrivateKey!);
        result['btcAddress'] = bitcoin
            .P2PKH(
              data: bitcoin.PaymentData(pubkey: btcKey.publicKey),
              network: network,
            )
            .data
            .address!;

        result['btcPrivateKey'] =
            hex.encode(btcKey.privateKey); // 使用 hex.encode
        result['btcWif'] = btcKey.toWIF();
      }

      return result;
    } catch (e) {
      print('恢复钱包失败: $e');
      return {};
    }
  }
}
