import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class WalletTockenBlance {
  //查询代币可用数量
  static Future<String> fetchTokenBalance(String address1) async {
    String balance = '';
    String address = address1; // 替换为你的地址
    const String tokenAddress =
        '0xf98BC3483c618b82B16367B606Cc3467E049B865'; //代币地址
    final response = await http.post(
      Uri.parse('https://rpc-amoy.polygon.technology'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'jsonrpc': '2.0',
        'method': 'eth_call',
        'params': [
          {
            'to': tokenAddress,
            'data':
                '0x70a08231000000000000000000000000${address.replaceFirst('0x', '')}',
          },
          'latest'
        ],
        'id': 1,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      String balanceHex = data['result'];
      // 将十六进制余额转换为十进制
      BigInt balanceInWei =
          BigInt.parse(balanceHex.replaceFirst('0x', ''), radix: 16);

      balance = balanceInWei.toString(); // 余额以 Wei 为单位

    } else {
      print('Failed to load token balance');
    }

    return balance;
  }

  //查询矿工费数量
  static Future<String> fetchBalance(String address1) async {
    String balance = '';
    String address = address1; // 替换为你的地址
    final response = await http.post(
      Uri.parse('https://rpc-amoy.polygon.technology'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'jsonrpc': '2.0',
        'method': 'eth_getBalance',
        'params': [address, 'latest'],
        'id': 1,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      String balanceHex = data['result'];
      // 将十六进制余额转换为十进制
      BigInt balanceInWei =
          BigInt.parse(balanceHex.replaceFirst('0x', ''), radix: 16);

      balance = balanceInWei.toString(); // 余额以 Wei 为单位

    } else {
      print('Failed to load balance');
    }
    return balance;
  }

// 授权代币

  Future<String> approveToken(
      String address1, String privateKey, BigInt amount1) async {
    try {
      // 1. 准备基础参数
      final tokenAddress =
          '0xf98BC3483c618b82B16367B606Cc3467E049B865'; //  代币合约
      final spenderAddress =
          "0xc31AB1159Ea848E4332549c996db53014d4aB933"; // 授权地址
      final amount = amount1 * BigInt.from(10).pow(18); // 转换为18位精度

      // 2. 构建RPC请求的基础URL和headers
      final rpcUrl = 'https://rpc-amoy.polygon.technology';
      final headers = {'Content-Type': 'application/json'};

      // 3. 获取 nonce
      final nonceResponse = await http.post(
        Uri.parse(rpcUrl),
        headers: headers,
        body: jsonEncode({
          'jsonrpc': '2.0',
          'method': 'eth_getTransactionCount',
          'params': [address1, 'latest'],
          'id': 1
        }),
      );

      final nonceHex = jsonDecode(nonceResponse.body)['result'];
      final nonce = int.parse(nonceHex.substring(2), radix: 16);
      print('Nonce: $nonce');

      // 4. 获取 gasPrice
      final gasPriceResponse = await http.post(
        Uri.parse(rpcUrl),
        headers: headers,
        body: jsonEncode({
          'jsonrpc': '2.0',
          'method': 'eth_gasPrice',
          'params': [],
          'id': 1
        }),
      );

      final gasPriceHex = jsonDecode(gasPriceResponse.body)['result'];
      final gasPrice = BigInt.parse(gasPriceHex.substring(2), radix: 16);
      print('Gas Price: $gasPrice');

      // 5. 构建approve的数据
      // approve(address,uint256) => 0x095ea7b3
      final methodId = '095ea7b3';
      final paddedAddress = spenderAddress.substring(2).padLeft(64, '0');
      final paddedAmount = amount.toRadixString(16).padLeft(64, '0');
      final data = '0x$methodId$paddedAddress$paddedAmount';

      // 6. 构建原始交易
      final rawTx = {
        'nonce': '0x${nonce.toRadixString(16)}',
        'gasPrice': gasPriceHex,
        'gas': '0x${BigInt.from(100000).toRadixString(16)}',
        'to': tokenAddress,
        'value': '0x0',
        'data': data,
        'chainId': 80002 // Polygon Mainnet
      };

      // 7. 签名交易
      if (privateKey.startsWith('0x')) {
        privateKey = privateKey.substring(2);
      }
      final credentials = EthPrivateKey.fromHex(privateKey);

      final client = Web3Client(rpcUrl, http.Client());
      try {
        final signedTx = await client.signTransaction(
          credentials,
          Transaction(
            nonce: nonce,
            gasPrice: EtherAmount.inWei(gasPrice),
            maxGas: 100000,
            to: EthereumAddress.fromHex(tokenAddress),
            value: EtherAmount.zero(),
            data: hexToBytes(data),
          ),
          chainId: 80002,
        );

        // 8. 发送签名后的交易
        final txResponse = await http.post(
          Uri.parse(rpcUrl),
          headers: headers,
          body: jsonEncode({
            'jsonrpc': '2.0',
            'method': 'eth_sendRawTransaction',
            'params': ['0x${bytesToHex(signedTx)}'],
            'id': 1
          }),
        );

        final txResult = jsonDecode(txResponse.body);
        if (txResult.containsKey('error')) {
          throw Exception(
              'Transaction failed: ${txResult['error']['message']}');
        }

        final txHash = txResult['result'];
        print('Transaction hash: $txHash');

        // 9. 等待交易确认
        bool confirmed = false;
        String? blockNumber;
        while (!confirmed) {
          final receiptResponse = await http.post(
            Uri.parse(rpcUrl),
            headers: headers,
            body: jsonEncode({
              'jsonrpc': '2.0',
              'method': 'eth_getTransactionReceipt',
              'params': [txHash],
              'id': 1
            }),
          );

          final receipt = jsonDecode(receiptResponse.body)['result'];
          if (receipt != null) {
            blockNumber = receipt['blockNumber'];
            confirmed = true;
          } else {
            await Future.delayed(Duration(seconds: 2));
          }
        }

        print('Transaction confirmed in block $blockNumber');
        return txHash;
      } finally {
        client.dispose();
      }
    } catch (e) {
      print('Error in approveToken: $e');
      rethrow;
    }
  }

// 计算方法 ID
  String getFunctionSelector(String functionSignature) {
    final bytes = keccakUtf8(functionSignature);
    return bytesToHex(bytes.sublist(0, 4));
  }

  // 购买基金
  Future<Map<String, BigInt>> buyFund(
    String privateKey,
    String fundAddress,
    String toAddress,
    String tokenAddress,
    BigInt amount,
  ) async {
    try {
      // 1. 准备基础参数
      final contractAddress =
          "0xc31AB1159Ea848E4332549c996db53014d4aB933"; // DApp合约地址
      final rpcUrl = 'https://rpc-amoy.polygon.technology';
      final headers = {'Content-Type': 'application/json'};

      // 2. 创建凭证
      if (privateKey.startsWith('0x')) {
        privateKey = privateKey.substring(2);
      }
      final credentials = EthPrivateKey.fromHex(privateKey);
      final address = await credentials.extractAddress();

      // 3. 获取 nonce
      final nonceResponse = await http.post(
        Uri.parse(rpcUrl),
        headers: headers,
        body: jsonEncode({
          'jsonrpc': '2.0',
          'method': 'eth_getTransactionCount',
          'params': [address.hex, 'latest'],
          'id': 1
        }),
      );

      final nonceHex = jsonDecode(nonceResponse.body)['result'];
      final nonce = int.parse(nonceHex.substring(2), radix: 16);

      // 4. 获取 gasPrice
      final gasPriceResponse = await http.post(
        Uri.parse(rpcUrl),
        headers: headers,
        body: jsonEncode({
          'jsonrpc': '2.0',
          'method': 'eth_gasPrice',
          'params': [],
          'id': 1
        }),
      );

      final gasPriceHex = jsonDecode(gasPriceResponse.body)['result'];
      final gasPrice = BigInt.parse(gasPriceHex.substring(2), radix: 16);

      // 5. 构建buyFund的调用数据
      final selector =
          getFunctionSelector('buyFund(address,address,address,uint256)');
      final methodId = selector;

      // 确保地址格式正确并移除 '0x' 前缀
      final cleanFundAddress = fundAddress.toLowerCase().replaceAll('0x', '');
      final cleanToAddress = toAddress.toLowerCase().replaceAll('0x', '');
      final cleanTokenAddress = tokenAddress.toLowerCase().replaceAll('0x', '');

      // 对参数进行编码
      final encodedFund = cleanFundAddress.padLeft(64, '0');
      final encodedTo = cleanToAddress.padLeft(64, '0');
      final encodedToken = cleanTokenAddress.padLeft(64, '0');
      final encodedAmount = amount.toRadixString(16).padLeft(64, '0');

      final data =
          '0x$methodId$encodedFund$encodedTo$encodedToken$encodedAmount';

      print('Transaction data: $data'); // 调试输出

      // 6. 构建交易
      final client = Web3Client(rpcUrl, http.Client());
      try {
        final signedTx = await client.signTransaction(
          credentials,
          Transaction(
            nonce: nonce,
            gasPrice: EtherAmount.inWei(gasPrice),
            maxGas: 300000,
            to: EthereumAddress.fromHex(contractAddress),
            value: EtherAmount.zero(),
            data: hexToBytes(data),
          ),
          chainId: 80002,
        );

        // 7. 发送交易
        final txResponse = await http.post(
          Uri.parse(rpcUrl),
          headers: headers,
          body: jsonEncode({
            'jsonrpc': '2.0',
            'method': 'eth_sendRawTransaction',
            'params': ['0x${bytesToHex(signedTx)}'],
            'id': 1
          }),
        );

        final txResult = jsonDecode(txResponse.body);
        if (txResult.containsKey('error')) {
          throw Exception(
              'Transaction failed: ${txResult['error']['message']}');
        }

        final txHash = txResult['result'];
        print('Transaction hash: $txHash');

        // 8. 等待交易确认并获取返回值
        bool confirmed = false;
        Map<String, BigInt> result = {};

        while (!confirmed) {
          final receiptResponse = await http.post(
            Uri.parse(rpcUrl),
            headers: headers,
            body: jsonEncode({
              'jsonrpc': '2.0',
              'method': 'eth_getTransactionReceipt',
              'params': [txHash],
              'id': 1
            }),
          );

          final receipt = jsonDecode(receiptResponse.body)['result'];
          if (receipt != null) {
            if (receipt['logs'] != null && receipt['logs'].length >= 1) {
              final log = receipt['logs'][0];
              final logData = log['data'];
              if (logData.length >= 130) {
                final shares =
                    BigInt.parse(logData.substring(2, 66), radix: 16);
                final value =
                    BigInt.parse(logData.substring(66, 130), radix: 16);
                result = {'shares': shares, 'value': value};
              }
            }
            confirmed = true;
          } else {
            await Future.delayed(Duration(seconds: 2));
          }
        }

        return result;
      } finally {
        client.dispose();
      }
    } catch (e) {
      print('Error in buyFund: $e');
      rethrow;
    }
  }

  // 查询基金账户信息
  Future<Map<String, BigInt>> getFundAccount(
    String fundAddress, // 基金地址
    String ownerAddress, // 用户地址
  ) async {
    try {
      // 1. 准备基础参数
      final contractAddress =
          "0xc31AB1159Ea848E4332549c996db53014d4aB933"; // DApp合约地址
      final rpcUrl = 'https://rpc-amoy.polygon.technology';
      final headers = {'Content-Type': 'application/json'};

      // 确保地址格式正确
      if (!fundAddress.startsWith('0x')) {
        fundAddress = '0x$fundAddress';
      }
      if (!ownerAddress.startsWith('0x')) {
        ownerAddress = '0x$ownerAddress';
      }

      print('Contract Address: $contractAddress');
      print('Fund Address: $fundAddress');
      print('Owner Address: $ownerAddress');

      // 2. 构建调用数据
      final methodId = getFunctionSelector('getFundAccount(address,address)');
      print('Method ID: $methodId');

      // 处理地址参数 - 移除0x前缀并填充到64位
      final cleanFundAddress =
          fundAddress.substring(2).toLowerCase().padLeft(64, '0');
      final cleanOwnerAddress =
          ownerAddress.substring(2).toLowerCase().padLeft(64, '0');

      // 组装调用数据
      final data = '0x$methodId$cleanFundAddress$cleanOwnerAddress';
      print('Call data: $data');

      // 3. 发送调用请求
      final response = await http.post(
        Uri.parse(rpcUrl),
        headers: headers,
        body: jsonEncode({
          'jsonrpc': '2.0',
          'method': 'eth_call',
          'params': [
            {
              'to': contractAddress, // DApp合约地址
              'from': ownerAddress, // 用户地址
              'data': data,
            },
            'latest'
          ],
          'id': 1
        }),
      );

      print('Response: ${response.body}');

      // 4. 处理返回结果
      final result = jsonDecode(response.body);
      if (result.containsKey('error')) {
        throw Exception(
            'Call failed: ${result['error']['message']} - ${result['error']['data']}');
      }

      // 解析返回数据
      final returnData = result['result'].toString();
      print('Return data: $returnData');

      if (returnData.length >= 194) {
        // 解析三个返回值：shares, value, cost
        final shares = BigInt.parse(returnData.substring(2, 66), radix: 16);
        final value = BigInt.parse(returnData.substring(66, 130), radix: 16);
        final cost = BigInt.parse(returnData.substring(130, 194), radix: 16);

        print('Shares: $shares');
        print('Value: $value');
        print('Cost: $cost');

        return {'shares': shares, 'value': value, 'cost': cost};
      }

      throw Exception('Invalid return data length: ${returnData.length}');
    } catch (e) {
      print('Error in getFundAccount: $e');
      rethrow;
    }
  }

  // 赎回基金
  Future<BigInt> redeemFund(
    String privateKey,
    String fundAddress, // 基金地址
    String toAddress, // 接收代币的地址
    BigInt shares, // 赎回的份额
  ) async {
    try {
      // 1. 准备基础参数
      final contractAddress =
          "0xc31AB1159Ea848E4332549c996db53014d4aB933"; // DApp合约地址
      final rpcUrl = 'https://rpc-amoy.polygon.technology';
      final headers = {'Content-Type': 'application/json'};

      // 确保地址格式正确
      if (!fundAddress.startsWith('0x')) {
        fundAddress = '0x$fundAddress';
      }
      if (!toAddress.startsWith('0x')) {
        toAddress = '0x$toAddress';
      }

      // 确保私钥格式正确
      if (privateKey.startsWith('0x')) {
        privateKey = privateKey.substring(2);
      }
      final credentials = EthPrivateKey.fromHex(privateKey);
      final address = await credentials.extractAddress();

      print('Contract Address: $contractAddress');
      print('Fund Address: $fundAddress');
      print('To Address: $toAddress');
      print('Shares: $shares');
      print('From Address: ${address.hex}'); // 添加调试输出

      // 3. 获取 nonce
      final nonceResponse = await http.post(
        Uri.parse(rpcUrl),
        headers: headers,
        body: jsonEncode({
          'jsonrpc': '2.0',
          'method': 'eth_getTransactionCount',
          'params': [address.hex, 'latest'],
          'id': 1
        }),
      );

      final nonceHex = jsonDecode(nonceResponse.body)['result'];
      final nonce = int.parse(nonceHex.substring(2), radix: 16);
      print('Nonce: $nonce'); // 添加调试输出

      // 4. 获取 gasPrice
      final gasPriceResponse = await http.post(
        Uri.parse(rpcUrl),
        headers: headers,
        body: jsonEncode({
          'jsonrpc': '2.0',
          'method': 'eth_gasPrice',
          'params': [],
          'id': 1
        }),
      );

      final gasPriceHex = jsonDecode(gasPriceResponse.body)['result'];
      final gasPrice = BigInt.parse(gasPriceHex.substring(2), radix: 16);
      print('Gas Price: $gasPrice'); // 添加调试输出

      // 5. 构建redeemFund的调用数据
      final methodId =
          getFunctionSelector('redeemFund(address,address,uint256)');
      print('Method ID: $methodId');

      // 处理参数
      final cleanFundAddress =
          fundAddress.substring(2).toLowerCase().padLeft(64, '0');
      final cleanToAddress =
          toAddress.substring(2).toLowerCase().padLeft(64, '0');
      final encodedShares = shares.toRadixString(16).padLeft(64, '0');

      // 组装调用数据
      final data = '0x$methodId$cleanFundAddress$cleanToAddress$encodedShares';
      print('Call data: $data');

      // 6. 构建交易
      final client = Web3Client(rpcUrl, http.Client());
      try {
        final signedTx = await client.signTransaction(
          credentials,
          Transaction(
            nonce: nonce,
            gasPrice: EtherAmount.inWei(gasPrice),
            maxGas: 300000,
            to: EthereumAddress.fromHex(contractAddress),
            value: EtherAmount.zero(),
            data: hexToBytes(data),
          ),
          chainId: 80002,
        );

        // 7. 发送交易
        final txResponse = await http.post(
          Uri.parse(rpcUrl),
          headers: headers,
          body: jsonEncode({
            'jsonrpc': '2.0',
            'method': 'eth_sendRawTransaction',
            'params': ['0x${bytesToHex(signedTx)}'],
            'id': 1
          }),
        );

        final txResult = jsonDecode(txResponse.body);
        if (txResult.containsKey('error')) {
          throw Exception(
              'Transaction failed: ${txResult['error']['message']}');
        }

        final txHash = txResult['result'];
        print('Transaction hash: $txHash');

        // 8. 等待交易确认并获取返回值
        bool confirmed = false;
        BigInt amount = BigInt.zero;

        while (!confirmed) {
          final receiptResponse = await http.post(
            Uri.parse(rpcUrl),
            headers: headers,
            body: jsonEncode({
              'jsonrpc': '2.0',
              'method': 'eth_getTransactionReceipt',
              'params': [txHash],
              'id': 1
            }),
          );

          final receipt = jsonDecode(receiptResponse.body)['result'];
          if (receipt != null) {
            if (receipt['logs'] != null && receipt['logs'].length >= 1) {
              final log = receipt['logs'][0];
              final logData = log['data'];
              if (logData.length >= 66) {
                amount = BigInt.parse(logData.substring(2), radix: 16);
              }
            }
            confirmed = true;
          } else {
            await Future.delayed(Duration(seconds: 2));
          }
        }

        return amount;
      } finally {
        client.dispose();
      }
    } catch (e) {
      print('Error in redeemFund: $e');
      rethrow;
    }
  }

// 在 WalletTockenBlance 类中添加新方法
  Future<String> signApproveTransaction({
    required String tokenAddress,
    required String spenderAddress,
    required BigInt amount,
    required String privateKey,
  }) async {
    try {
      const String rpcUrl = 'https://rpc-amoy.polygon.technology';
      final client = Web3Client(rpcUrl, http.Client());

      try {
        // 创建凭证
        final credentials =
            EthPrivateKey.fromHex(privateKey.replaceFirst('0x', ''));
        final address = await credentials.extractAddress();

        // 创建合约 ABI
        final abi = ContractAbi.fromJson(
          '''[{
          "constant": false,
          "inputs": [
            {"name": "spender", "type": "address"},
            {"name": "value", "type": "uint256"}
          ],
          "name": "approve",
          "outputs": [{"name": "", "type": "bool"}],
          "payable": false,
          "stateMutability": "nonpayable",
          "type": "function"
        }]''',
          'ERC20',
        );

        // 创建合约实例
        final contract = DeployedContract(
          abi,
          EthereumAddress.fromHex(tokenAddress),
        );

        // 获取 approve 函数
        final approveFunction = contract.function('approve');

        // 准备交易数据
        final data = approveFunction.encodeCall([
          EthereumAddress.fromHex(spenderAddress),
          amount,
        ]);

        // 获取 nonce
        final nonce = await client.getTransactionCount(address);
        print('Nonce: $nonce');

        // 获取 gas 价格
        final gasPrice = BigInt.from(28000000000); // 28 Gwei
        print('Gas Price: $gasPrice');

        // 估算 gas limit
        final gasLimit = await client.estimateGas(
          sender: address,
          to: EthereumAddress.fromHex(tokenAddress),
          data: data,
        );
        print('Gas Limit: $gasLimit');

        // 构建交易
        final transaction = Transaction(
          to: EthereumAddress.fromHex(tokenAddress),
          from: address,
          nonce: nonce,
          gasPrice: EtherAmount.inWei(gasPrice),
          maxGas: gasLimit.toInt(),
          value: EtherAmount.zero(),
          data: data,
        );

        // 签名交易
        final signedTx = await client.signTransaction(
          credentials,
          transaction,
          chainId: 80002, // Mumbai 测试网
        );

        print('Signed transaction: 0x${bytesToHex(signedTx)}');

        // 可选：发送交易
        // final txHash = await client.sendRawTransaction(signedTx);
        // print('Transaction hash: $txHash');

        return '0x${bytesToHex(signedTx)}';
      } finally {
        client.dispose();
      }
    } catch (e) {
      print('Error in signApproveTransaction: $e');
      rethrow;
    }
  }

  // 查询授权额度
  static Future<String> fetchAllowance(
      String ownerAddress, String spenderAddress) async {
    const String tokenAddress =
        '0xf98BC3483c618b82B16367B606Cc3467E049B865'; // 代币地址

    // allowance(address,address) 方法的 selector: 0xdd62ed3e
    final data = '0xdd62ed3e' +
        ownerAddress.replaceFirst('0x', '').padLeft(64, '0') +
        spenderAddress.replaceFirst('0x', '').padLeft(64, '0');

    final response = await http.post(
      Uri.parse('https://rpc-amoy.polygon.technology'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'jsonrpc': '2.0',
        'method': 'eth_call',
        'params': [
          {
            'to': tokenAddress,
            'data': data,
          },
          'latest'
        ],
        'id': 1,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      String allowanceHex = data['result'];
      // 将十六进制余额转换为十进制
      BigInt allowanceInWei =
          BigInt.parse(allowanceHex.replaceFirst('0x', ''), radix: 16);
      print('Allowance: $allowanceInWei');
      return allowanceInWei.toString();
    } else {
      throw Exception('Failed to load allowance');
    }
  }

  // 检查授权额度是否足够
  static Future<bool> checkAllowance({
    required String ownerAddress,
    required String spenderAddress,
    required BigInt requiredAmount,
  }) async {
    try {
      final allowance = await fetchAllowance(ownerAddress, spenderAddress);
      final allowanceAmount = BigInt.parse(allowance);
      print('Allowance: $allowanceAmount');
      print('Required Amount: $requiredAmount');
      return allowanceAmount >= requiredAmount;
    } catch (e) {
      print('检查授权额度失败: $e');
      return false;
    }
  }
}
