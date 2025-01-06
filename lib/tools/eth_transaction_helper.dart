import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EthTransactionHelper {
  late InAppWebViewController _webViewController;
  bool _isInitialized = false;
  String? _lastSignature;

  Future<void> initialize() async {
    final ethersJs = await rootBundle.loadString('lib/tools/ethers_umd_min.js');

    final headlessWebView = HeadlessInAppWebView(
      initialData: InAppWebViewInitialData(data: '''
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <script>
            $ethersJs

            window.lastSignature = null;
            
            window.signMessage = async function(domain, types, value, privateKey) {
              try {
                const wallet = new ethers.Wallet(privateKey);
                const signature = await wallet._signTypedData(domain, types, value);
                console.log('Signature generated:', signature);
                window.lastSignature = signature;
                return true;
              } catch (error) {
                console.error('Signing error:', error);
                return false;
              }
            }

            window.getLastSignature = function() {
              return window.lastSignature;
            }
          </script>
        </head>
        <body></body>
        </html>
      '''),
      onWebViewCreated: (controller) {
        _webViewController = controller;
      },
      onLoadStop: (controller, url) {
        _isInitialized = true;
      },
      onConsoleMessage: (controller, consoleMessage) {
        final message = consoleMessage.message;
        print("WebView Console: $message");

        // 从控制台日志中提取签名
        if (message.startsWith('Signature generated: ')) {
          _lastSignature = message.substring('Signature generated: '.length);
        }
      },
    );

    await headlessWebView.run();
    await Future.delayed(Duration(seconds: 1));
  }

  Future<String> signSwapTransaction({
    required String tokenAddress,
    required BigInt amountIn,
    required BigInt amountOut,
  }) async {
    if (!_isInitialized) {
      throw Exception('WebView not initialized');
    }

    final domain = {
      'name': 'entry',
      'version': '1',
      'chainId': 80002,
      'verifyingContract': '0xc31AB1159Ea848E4332549c996db53014d4aB933'
    };

    final types = {
      'SwapETH': [
        {'name': 'owner', 'type': 'address'},
        {'name': 'token', 'type': 'address'},
        {'name': 'amountIn', 'type': 'uint256'},
        {'name': 'amountOut', 'type': 'uint256'},
        {'name': 'nonce', 'type': 'uint256'},
        {'name': 'deadline', 'type': 'uint256'},
      ]
    };
    final deadline = DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600;
    const rpcUrl = 'https://rpc-amoy.polygon.technology';
    final address = "0x5e96dc0c4a3c0cdeea7f8d45451d8804a0659349";
    final headers = {'Content-Type': 'application/json'};
    // 3. 获取 nonce
    final nonceResponse = await http.post(
      Uri.parse(rpcUrl),
      headers: headers,
      body: jsonEncode({
        'jsonrpc': '2.0',
        'method': 'eth_getTransactionCount',
        'params': [address, 'latest'],
        'id': 1
      }),
    );

    final nonceData = jsonDecode(nonceResponse.body);
    final nonce = int.parse(nonceData['result'].substring(2), radix: 16);

    final value = {
      'owner': '0x5e96dc0c4a3c0cdeea7f8d45451d8804a0659349',
      'token': tokenAddress,
      'amountIn': amountIn.toString(),
      'amountOut': amountOut.toString(),
      'nonce': nonce,
      'deadline': deadline.toString(),
    };

    final privateKey =
        '0x896465cb9be7d4da1b06d5b9ef1dc0715527dc4d1bb18dd149318c5cf4ea0af9';

    try {
      print('Calling signMessage with params:');
      print('Domain: $domain');
      print('Types: $types');
      print('Value: $value');

      // 重置上一次的签名
      _lastSignature = null;

      // 调用签名方法
      final success = await _webViewController.evaluateJavascript(
        source:
            'window.signMessage(${jsonEncode(domain)}, ${jsonEncode(types)}, ${jsonEncode(value)}, "$privateKey")',
      );

      // 等待一小段时间，确保控制台消息被处理
      await Future.delayed(Duration(milliseconds: 100));

      // 从 JavaScript 中获取签名结果
      final signature = await _webViewController.evaluateJavascript(
        source: 'window.getLastSignature()',
      );

      if (signature == null || _lastSignature == null) {
        throw Exception('签名返回为空');
      }

      return _lastSignature!;
    } catch (e) {
      print('签名失败: $e');
      rethrow;
    }
  }

  BigInt parseUnits(String value, int decimals) {
    final number = double.parse(value);
    final factor = BigInt.from(10).pow(decimals);
    return BigInt.from(number * factor.toDouble());
  }
}
