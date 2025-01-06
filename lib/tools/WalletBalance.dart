import 'dart:async';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:web3dart/web3dart.dart';
import 'package:web3dart/crypto.dart';
import 'package:flutter_bitcoin/flutter_bitcoin.dart' as bitcoin;
import 'dart:io';

class WalletBalance {
// ERC20 合约 ABI
  static const String erc20Abi = '''
[
  {
    "constant": false,
    "inputs": [
      {
        "name": "to",
        "type": "address"
      },
      {
        "name": "value",
        "type": "uint256"
      }
    ],
    "name": "transfer",
    "outputs": [
      {
        "name": "",
        "type": "bool"
      }
    ],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  }
]
''';

  // 获取BTC余额
  Future<double> getBTCBalance(String address, bool isTestnet) async {
    try {
      // 使用 Blockstream API
      final baseUrl = isTestnet
          ? 'https://blockstream.info/api/address/'
          : 'https://blockstream.info/testnet/api/address/';

      final response = await http.get(Uri.parse('$baseUrl$address'));
      print('Blockstream API Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // 计算实际余额：收到的金额 - 花费的金额
        final balance = (data['chain_stats']['funded_txo_sum'] -
                data['chain_stats']['spent_txo_sum']) /
            100000000.0;
        print('地址: $address');
        print('收到: ${data['chain_stats']['funded_txo_sum']} 聪');
        print('花费: ${data['chain_stats']['spent_txo_sum']} 聪');
        print('余额: $balance BTC');
        return balance;
      }
      return 0.0;
    } catch (e) {
      print('获取BTC余额失败: $e');
      return 0.0;
    }
  }

// 获取EVM余额
  Future<double> getEVMBalance(String address) async {
    try {
      final client = Web3Client(
        'https://rpc-amoy.polygon.technology',
        http.Client(),
      );
// https://mainnet.infura.io/v3/1c84195eea1245faa4002d8fd3b7e378
      // final String infuraUrl = 'https://sepolia.infura.io/v3/YOUR-PROJECT-ID';  // Sepolia测试网
      // final String infuraUrl = 'https://goerli.infura.io/v3/YOUR-PROJECT-ID';   // Goerli测试网

      final balance = await client.getBalance(EthereumAddress.fromHex(address));
      client.dispose(); // 记得关闭连接
      return balance.getValueInUnit(EtherUnit.ether);
    } catch (e) {
      print('获取EVM余额失败: $e');
      return 0.0;
    }
  }

// 获取EVM交易历史
  Future<List<Map<String, dynamic>>> getEVMTransactions(String address) async {
    try {
      // 使用 Etherscan API
      final apiKey = 'JXY2U3SQA4INU888NIHC2IVP1FKMJFR5CB';

      // 正确构建 URL
      final url = Uri.parse('https://api.etherscan.io/api'
          '?module=account'
          '&action=txlist'
          '&address=$address'
          '&startblock=0'
          '&endblock=99999999'
          '&sort=desc'
          '&apikey=$apiKey');

      print('请求 URL: $url');
      final response = await http.get(url).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('请求超时，请检查网络连接');
        },
      );

      if (response.statusCode != 200) {
        print('API 请求失败: ${response.statusCode}');
        print('响应内容: ${response.body}');
        return [];
      }

      final data = json.decode(response.body);
      print('API 响应: $data');

      if (data['status'] == '1' && data['message'] == 'OK') {
        return (data['result'] as List).map((tx) {
          // 计算 ETH 金额
          final value = BigInt.parse(tx['value']);
          final ethValue = value / BigInt.from(10).pow(18);

          return {
            'hash': tx['hash'],
            'from': tx['from'],
            'to': tx['to'],
            'value': ethValue.toString(),
            'timestamp': DateTime.fromMillisecondsSinceEpoch(
                    int.parse(tx['timeStamp']) * 1000)
                .toString(),
            'type':
                tx['from'].toLowerCase() == address.toLowerCase() ? '转出' : '转入',
            'status': tx['isError'] == '0' ? '成功' : '失败',
            'gasUsed': tx['gasUsed'],
            'gasPrice': tx['gasPrice'],
          };
        }).toList();
      }

      print('没有找到交易记录');
      return [];
    } catch (e) {
      print('获取 EVM 交易历史失败: $e');
      return [];
    }
  }

// 测试BTC交易历史
  Future<List<Map<String, dynamic>>> getBTCTestnetTransactions(
      String address) async {
    try {
      final url = Uri.parse(
          'https://blockstream.info/testnet/api/address/$address/txs');

      final response = await http.get(url).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('请求超时');
        },
      );

      if (response.statusCode != 200) {
        print('API 请求失败: ${response.statusCode}');
        return [];
      }

      final List<dynamic> transactions = json.decode(response.body);

      return transactions.map((tx) {
        int inputAmount = 0; // 输入总额
        int outputAmount = 0; // 输出总额
        bool isInvolved = false;

        // 计算与我们地址相关的输入金额
        for (var input in tx['vin']) {
          if (input['prevout']['scriptpubkey_address'] == address) {
            inputAmount += input['prevout']['value'] as int;
            isInvolved = true;
          }
        }

        // 计算与我们地址相关的输出金额
        for (var output in tx['vout']) {
          if (output['scriptpubkey_address'] == address) {
            outputAmount += output['value'] as int;
            isInvolved = true;
          }
        }

        // 计算实际交易金额和方向
        bool isReceiving = outputAmount > inputAmount;
        int actualAmount = isReceiving ? outputAmount : inputAmount;

        // 如果是转出交易，需要减去找零金额
        if (!isReceiving && outputAmount > 0) {
          actualAmount -= outputAmount;
        }

        return {
          'hash': tx['txid'],
          'value': (actualAmount / 100000000).toString(), // 转换为 BTC 单位
          'timestamp': DateTime.fromMillisecondsSinceEpoch(
                  tx['status']['block_time'] * 1000)
              .toString(),
          'type': isReceiving ? '转入' : '转出',
          'status': tx['status']['confirmed'] ? '成功' : '待确认',
          'blockHeight': tx['status']['block_height'],
          'fee': tx['fee'] != null ? (tx['fee'] / 100000000).toString() : '0',
        };
      }).toList();
    } catch (e) {
      print('获取 BTC 测试网交易历史失败: $e');
      return [];
    }
  }

  // BTC 交易历史 -- 正式
  Future<List<Map<String, dynamic>>> getBTCTransactions(
      String address, bool isTestnet) async {
    try {
      final apiUrl = 'https://blockchain.info/rawaddr/$address';

//  final url = Uri.parse('https://blockchain.info/rawaddr/$address');//主网好用的地址 bc1pk26zd7pyud70uwdu7s95e9rjgy3ryzvfam9w84eentmxmpn0n7us0f0kqr

      print('apiUrl地址: $apiUrl');
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to get transactions');
      }

      final data = json.decode(response.body);
      print('data返回值: $data');
      List<Map<String, dynamic>> transactions = [];

      for (var tx in data['txs']) {
        // 计算交易类型和金额
        double value = 0;
        String type = 'unknown';

        // 检查输入
        bool isFromAddress = tx['inputs']
            .any((input) => input['addresses']?.contains(address) ?? false);

        // 检查输出
        bool isToAddress = tx['outputs']
            .any((output) => output['addresses']?.contains(address) ?? false);

        if (isFromAddress) {
          type = 'sent';
          // 计算发送金额
          value = tx['outputs']
                  .where((output) =>
                      !(output['addresses']?.contains(address) ?? false))
                  .map((output) => output['value'])
                  .fold(0, (a, b) => a + b) /
              100000000; // 转换为 BTC
        } else if (isToAddress) {
          type = 'received';
          // 计算接收金额
          value = tx['outputs']
                  .where((output) => output['addresses']?.contains(address))
                  .map((output) => output['value'])
                  .fold(0, (a, b) => a + b) /
              100000000; // 转换为 BTC
        }

        transactions.add({
          'hash': tx['hash'],
          'type': type,
          'value': value,
          'confirmations': tx['confirmations'],
          'timestamp': tx['received'],
          'fees': tx['fees'] / 100000000, // 转换为 BTC
        });
      }

      return transactions;
    } catch (e) {
      print('获取BTC交易历史失败: $e');
      return [];
    }
  }

  final String rpcUrl = 'https://rpc-amoy.polygon.technology';
// 发送交易的函数
  Future<String?> sendTransaction({
    required String fromPrivateKey, // 发送方私钥
    required String toAddress, // 接收方地址
    required double amount, // 转账金额
    required String currency, // 货币类型: 'ETH', 'BTU', 'USDT', 'USDC'
  }) async {
    try {
      final client = Web3Client(rpcUrl, http.Client());

      // 1. 创建凭证
      final credentials = EthPrivateKey.fromHex(fromPrivateKey);
      // final sender = await credentials.extractAddress();

      // 2. 根据货币类型构建交易
      if (currency == 'ETH') {
        // 发送 ETH 或 BTU
        final transaction = Transaction(
          to: EthereumAddress.fromHex(toAddress),
          value: EtherAmount.fromUnitAndValue(
            EtherUnit.ether,
            BigInt.from(amount * (10 ^ 18)), // 根据精度调整
          ),
          maxGas: 100000, // 设置 gas 限制
        );

        // 3. 发送交易
        final txHash = await client.sendTransaction(
          credentials,
          transaction,
          chainId: 1337, // Ganache 的 chainId
        );

        print('交易已发送，交易哈希: $txHash');
        return txHash;
      } else if (currency == 'BTU') {
        // 发送 BTU
        String tokenAddress = 'BTU 合约地址'; // 替换为 BTU 的合约地址

        // 1. 创建代币合约实例
        final contract = DeployedContract(
          ContractAbi.fromJson(erc20Abi, 'ERC20'),
          EthereumAddress.fromHex(tokenAddress),
        );

        // 2. 获取 transfer 方法
        final transferFunction = contract.function('transfer');

        // 3. 构建交易
        final transaction = Transaction(
          to: EthereumAddress.fromHex(tokenAddress),
          value: EtherAmount.fromUnitAndValue(
              EtherUnit.ether, BigInt.zero), // ERC20 代币转账不需要 ETH
          data: transferFunction.encodeCall([
            EthereumAddress.fromHex(toAddress),
            BigInt.from(amount * (10 ^ 18)), // 根据代币的精度调整
          ]),
          maxGas: 100000, // 设置 gas 限制
        );

        // 4. 发送交易
        final txHash = await client.sendTransaction(
          credentials,
          transaction,
          chainId: 1337, // Ganache 的 chainId
        );

        print('BTU 交易已发送，交易哈希: $txHash');
        return txHash;
      } else if (currency == 'USDT' || currency == 'USDC') {
        // 发送 USDT 或 USDC
        String tokenAddress = currency == 'USDT'
            ? '0xdac17f958d2ee523a2206206994597c13d831ec7' // USDT 合约地址
            : '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48'; // USDC 合约地址

        // 2. 创建代币合约实例
        final contract = DeployedContract(
          ContractAbi.fromJson(erc20Abi, 'ERC20'),
          EthereumAddress.fromHex(tokenAddress),
        );

        // 3. 获取 transfer 方法
        final transferFunction = contract.function('transfer');

        // 4. 构建交易
        final transaction = Transaction(
          to: EthereumAddress.fromHex(tokenAddress),
          value: EtherAmount.fromUnitAndValue(
              EtherUnit.ether, BigInt.zero), // ERC20 代币转账不需要 ETH
          data: transferFunction.encodeCall([
            EthereumAddress.fromHex(toAddress),
            BigInt.from(amount * (10 ^ 18)), // 根据代币的精度调整
          ]),
          maxGas: 100000, // 设置 gas 限制
        );

        // 5. 发送交易
        final txHash = await client.sendTransaction(
          credentials,
          transaction,
          chainId: 1337, // Ganache 的 chainId
        );

        print('交易已发送，交易哈希: $txHash');
        return txHash;
      } else {
        print('不支持的货币类型: $currency');
        return null;
      }
    } catch (e) {
      print('转账失败: $e');
      return null;
    }
  }

  // // 转账方法
  // Future<String?> sendTransaction({
  //   required String fromPrivateKey, // 发送方私钥
  //   required String toAddress, // 接收方地址
  //   required double amount, // 转账金额(ETH)
  // }) async {
  //   try {
  //     final client = Web3Client(rpcUrl, http.Client());

  //     // 1. 创建凭证
  //     final credentials = EthPrivateKey.fromHex(fromPrivateKey);
  //     final sender = await credentials.extractAddress();

  //     // 2. 构建交易
  //     final transaction = Transaction(
  //       to: EthereumAddress.fromHex(toAddress),
  //       value: EtherAmount.fromUnitAndValue(
  //         EtherUnit.ether,
  //         BigInt.from(amount),
  //       ),
  //       maxGas: 100000, // 设置 gas 限制
  //     );

  //     // 3. 发送交易
  //     final txHash = await client.sendTransaction(
  //       credentials,
  //       transaction,
  //       chainId: 1337, // Ganache 的 chainId
  //     );

  //     // 4. 关闭客户端
  //     client.dispose();

  //     print('交易已发送，交易��希: $txHash');
  //     return txHash;
  //   } catch (e) {
  //     print('转账失败: $e');
  //     return null;
  //   }
  // }

  // BTC 转账方法
  Future<String?> sendBTCTransaction({
    required String fromAddress,
    required String privateKeyWIF,
    required String toAddress,
    required double amount,
    required bool isTestnet,
  }) async {
    try {
      final network = isTestnet ? bitcoin.testnet : bitcoin.bitcoin;
      print('使用网络: ${isTestnet ? "测试网" : "主网"}');

      final keyPair = bitcoin.ECPair.fromWIF(privateKeyWIF, network: network);
      print('私钥导入成功');

      // 获取已确认的 UTXO
      final utxos = await _getBTCUtxos(fromAddress, isTestnet);
      print('获取到的 UTXO: ${json.encode(utxos)}');

      if (utxos.isEmpty) {
        throw Exception('没有可用的已确认 UTXO');
      }

      // 创建交易
      final txb = bitcoin.TransactionBuilder(network: network);
      final amountInSatoshi = (amount * 100000000).toInt();
      var totalInput = 0;

      // 添加输入
      for (var utxo in utxos) {
        print('\n使用 UTXO:');
        print('交易哈希: ${utxo['tx_hash']}');
        print('输���索引: ${utxo['tx_output_n']}');
        print('金额: ${utxo['value']} 聪');
        print('确认数: ${utxo['confirmations']}');

        txb.addInput(
          utxo['tx_hash'], // 交易哈希
          utxo['tx_output_n'], // 输出索引
        );
        totalInput += utxo['value'] as int;
      }

      // 设置手续费（增加手续费以加快确认）
      final fee = 1000; // 增加到 5000 satoshis

      // 检查余额
      if (totalInput < amountInSatoshi + fee) {
        throw Exception(
            '余额不足 (需要: ${amountInSatoshi + fee} satoshi, 实际: $totalInput satoshi)');
      }

      // 添加输出
      txb.addOutput(toAddress, amountInSatoshi);
      print('添加输出到: $toAddress, 金额: $amountInSatoshi satoshi');

      // 添加找零
      final change = totalInput - amountInSatoshi - fee;
      if (change > 546) {
        txb.addOutput(fromAddress, change);
        print('添加找零到: $fromAddress, 金额: $change satoshi');
      }

      // 签名所有输入
      for (var i = 0; i < utxos.length; i++) {
        txb.sign(vin: i, keyPair: keyPair);
        print('签名输入 #$i');
      }

      // 构建并序列化交易
      final tx = txb.build();
      final rawTx = tx.toHex();
      print('原始交易数据: $rawTx');

      // 广播交易
      return await broadcastTransaction1(rawTx, isTestnet);
    } catch (e) {
      print('BTC转账失败: $e');
      return null;
    }
  }

  Future<String?> broadcastTransaction1(String rawTx, bool isTestnet) async {
    try {
      final url = isTestnet
          ? 'https://blockstream.info/testnet/api/tx'
          : 'https://blockstream.info/api/tx';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'text/plain'},
        body: rawTx,
      );

      print('交易数据: $rawTx');
      print('API响应: ${response.body}');

      if (response.statusCode == 200) {
        return response.body; // 返回交易哈希
      }

      throw Exception('广播交易失败: ${response.body}');
    } catch (e) {
      print('广播交易失败: $e');
      return null;
    }
  }

  // 获取 UTXO 的新方法
  Future<List<Map<String, dynamic>>> _getBTCUtxos(
      String address, bool isTestnet) async {
    try {
      // 使用 Blockstream API 获取 UTXO
      final baseUrl = isTestnet
          ? 'https://blockstream.info/testnet/api/address/$address/utxo'
          : 'https://blockstream.info/api/address/$address/utxo';

      final response = await http.get(Uri.parse(baseUrl));
      print('UTXO API Response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> utxos = json.decode(response.body);
        return utxos.map((utxo) {
          print('找到 UTXO:');
          print('- 交易哈希: ${utxo['txid']}');
          print('- 输出索引: ${utxo['vout']}');
          print('- 金额: ${utxo['value']} satoshis');

          return {
            'tx_hash': utxo['txid'],
            'tx_output_n': utxo['vout'],
            'value': utxo['value'],
            'confirmations': utxo['status']['confirmed'] ? 1 : 0,
          };
        }).toList();
      }
      return [];
    } catch (e) {
      print('获取 UTXO 失败: $e');
      return [];
    }
  }

  // 获取交易状态
  Future<String?> sendBTCTransactionStatus(
      String txHash, bool isTestnet) async {
    try {
      final apiUrl = isTestnet
          ? 'https://api.blockcypher.com/v1/btc/test3/txs/$txHash'
          : 'https://api.blockcypher.com/v1/btc/main/txs/$txHash';

      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode != 200) {
        return null;
      }

      final data = json.decode(response.body);
      return data['confirmations'] > 0 ? data['hash'] : null;
    } catch (e) {
      print('获取BTC交易状态失败: $e');
      return null;
    }
  }

  // 获��� EVM 交易状态
  Future<bool> getTransactionStatus(String txHash) async {
    try {
      final client = Web3Client(rpcUrl, http.Client());

      // 获取交易收据
      final receipt = await client.getTransactionReceipt(txHash);

      // 关闭客户端连接
      client.dispose();

      // 如果收据存在且状态为 1，则表示交易成功
      return receipt != null && receipt.status!;
    } catch (e) {
      print('获取交易状态失败: $e');
      return false;
    }
  }

  // 验证 UTXO 是否可用
  Future<bool> _verifyUTXO(String txHash, int vout, bool isTestnet) async {
    try {
      final url = isTestnet
          ? 'https://blockstream.info/testnet/api/tx/$txHash'
          : 'https://blockstream.info/api/tx/$txHash';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        return false;
      }

      final data = json.decode(response.body);
      // 检查交易是否已确认
      if (!data['status']['confirmed']) {
        return false;
      }

      // 检查输出是否存在且未被花费
      if (data['vout'].length <= vout) {
        return false;
      }

      return true;
    } catch (e) {
      print('验证 UTXO 失败: $e');
      return false;
    }
  }

  Future<String?> broadcastTransaction(String rawTx, bool isTestnet) async {
    try {
      final url = isTestnet
          ? 'https://blockstream.info/testnet/api/tx'
          : 'https://blockstream.info/api/tx';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'text/plain'},
        body: rawTx,
      );

      if (response.statusCode == 200) {
        // 成功时返回交易ID
        return response.body;
      } else {
        print('广播失败: ${response.body}');
        return null;
      }
    } catch (e) {
      print('广播异常: $e');
      return null;
    }
  }

  // 检查余额和 UTXO
  Future<void> checkBTCStatus(String address, bool isTestnet) async {
    try {
      // 使用 Blockstream API
      final baseUrl = isTestnet
          ? 'https://blockstream.info/testnet/api/address/'
          : 'https://blockstream.info/api/address/';

      // 获取地址信息
      final response = await http.get(Uri.parse('$baseUrl$address'));
      print('地址信息: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('\n当前状态:');
        print('总收到: ${data['chain_stats']['funded_txo_sum']} 聪');
        print('已花费: ${data['chain_stats']['spent_txo_sum']} 聪');
        print(
            '当前余额: ${data['chain_stats']['funded_txo_sum'] - data['chain_stats']['spent_txo_sum']} 聪');

        // 获取 UTXO
        final utxoResponse = await http.get(Uri.parse('$baseUrl$address/utxo'));
        if (utxoResponse.statusCode == 200) {
          final utxos = json.decode(utxoResponse.body) as List;
          print('\n可用 UTXO:');
          for (var utxo in utxos) {
            print('- 交易哈希: ${utxo['txid']}');
            print('- 输出索引: ${utxo['vout']}');
            print('- 金额: ${utxo['value']} 聪');
            print('- 已确认: ${utxo['status']['confirmed']}');
          }
        }

        // 获取最近交易
        final txsResponse = await http.get(Uri.parse('$baseUrl$address/txs'));
        if (txsResponse.statusCode == 200) {
          final txs = json.decode(txsResponse.body) as List;
          print('\n最近交易:');
          for (var tx in txs) {
            print('- 交易哈希: ${tx['txid']}');
            print('- 已确认: ${tx['status']['confirmed']}');
          }
        }
      }
    } catch (e) {
      print('检查状态失败: $e');
    }
  }
}
