import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purse_for_evmorbtc/tools/Adapt.dart';
import 'package:purse_for_evmorbtc/tools/WalletTockenBlance.dart';
import 'package:web3dart/web3dart.dart';

import '../../tools/eth_transaction_helper.dart';

class SubscribePage extends StatefulWidget {
  const SubscribePage({Key? key}) : super(key: key);

  @override
  _SubscribePageState createState() => _SubscribePageState();
}

class _SubscribePageState extends State<SubscribePage> {
  String amount = '0.01';
  String availableAmount = "";
  String selectedCurrency = 'SOL';
  double expectedReturn = 11.20;
  int lockDays = 5;
  late final Map<String, dynamic> itemData;
  TextEditingController amountController = TextEditingController();
  // final EthTransactionHelper ethTransactionHelper = EthTransactionHelper();

  @override
  void initState() {
    super.initState();
    itemData = Get.arguments["item"];

    WalletTockenBlance.fetchBalance(Get.arguments["evmAddress"]!).then((value) {
      if (double.parse(value) / pow(10, 18) < 0.005) {
        // 点击跳转到充值页面
        Get.toNamed('/GasExchangePage', arguments: {
          // "currentNetwork": networkController.network,
          // "account": networkController.account
        });
      } else {
        WalletTockenBlance.fetchTokenBalance(Get.arguments["evmAddress"]!)
            .then((value) {
          setState(() {
            availableAmount = (double.parse(value) / pow(10, 8)).toString();
          });
          checkAndPay();
        });
      }

      // print((double.parse(value) / pow(10, 18)).toString());
    });

    // approveTockenCoin();
  }

  noneGasBuy() async {
    try {
      final helper = EthTransactionHelper();
      await helper.initialize();

      final signature = await helper.signSwapTransaction(
        tokenAddress: "0xf98BC3483c618b82B16367B606Cc3467E049B865",
        amountIn: helper.parseUnits('24', 6),
        amountOut: helper.parseUnits('0.002', 18),
      );

      print('签名成功: $signature');
    } catch (e) {
      print('错误: $e');
    }

//长签名成功
    try {
      final walletTockenBlance = WalletTockenBlance();

      final signedTx = await walletTockenBlance.signApproveTransaction(
        tokenAddress: "0xf98BC3483c618b82B16367B606Cc3467E049B865", // 代币地址
        spenderAddress:
            "0xc31AB1159Ea848E4332549c996db53014d4aB933", // Entry 合约地址
        amount: BigInt.from(1000000000000000), // 0.001 * 10^18
        privateKey:
            "0x896465cb9be7d4da1b06d5b9ef1dc0715527dc4d1bb18dd149318c5cf4ea0af9",
      );

      print('签名成功: $signedTx');

      // 如果需要发送交易，可以使用 web3dart 的 sendRawTransaction
      // final txHash = await client.sendRawTransaction(hexToBytes(signedTx.substring(2)));
      // print('Transaction hash: $txHash');
    } catch (e) {
      print('错误: $e');
    }
  }

// 购买
  buyFundFun() async {
    try {
      final result = await WalletTockenBlance().buyFund(
          "0x896465cb9be7d4da1b06d5b9ef1dc0715527dc4d1bb18dd149318c5cf4ea0af9", // 私钥
          "0x63cD86B755eD1000BeE1a7C750fA7D57262E100f", // 基金合约地址
          "0x5e96dc0c4a3c0cdeea7f8d45451d8804a0659349", // 接收基金份额的地址（通常是自己的地址）
          "0xf98BC3483c618b82B16367B606Cc3467E049B865", // 代币的地址
          BigInt.from(10000000000) // 支付代币的数量
          );

      print('购买成功！');
      print('获得基金份额: ${result['shares']}');
      print('支付金额: ${result['value']}');

      WalletTockenBlance.fetchTokenBalance(Get.arguments["evmAddress"]!)
          .then((value) {
        setState(() {
          availableAmount = (double.parse(value) / pow(10, 18)).toString();
        });
        print(availableAmount);
      });
      WalletTockenBlance.fetchBalance(Get.arguments["evmAddress"]!)
          .then((value) {
        // setState(() {
        //   availableAmount = (double.parse(value) / pow(10, 18)).toString();
        // });
        print((double.parse(value) / pow(10, 18)).toString());
      });
    } catch (e) {
      print('购买失败: $e');
    }
  }

  Future<bool> checkAndPay({int andPay = 5000000000000000}) async {
    try {
      final ownerAddress = Get.arguments["evmAddress"];
      final spenderAddress =
          "0xc31AB1159Ea848E4332549c996db53014d4aB933"; // Entry 合约地址
      final requiredAmount = BigInt.from(andPay); // 需要支付的金额

      // 检查授权额度
      final isAllowanceEnough = await WalletTockenBlance.checkAllowance(
        ownerAddress: ownerAddress,
        spenderAddress: spenderAddress,
        requiredAmount: requiredAmount,
      );
      print('isAllowanceEnough: $isAllowanceEnough');
      if (!isAllowanceEnough) {
        // 如果授权额度不足，先进行授权
        Get.toNamed('/AccreditPage', arguments: {
          "evmAddress": ownerAddress,
          "spenderAddress": spenderAddress,
          "requiredAmount": requiredAmount.toString(),
          "availableAmount": availableAmount.toString(),
          "item": itemData,
        });
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print('错误: $e');
      Get.snackbar(
        '错误',
        '交易失败: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    // return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF110A3A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            'lib/images/ic_return.png',
            width: 24,
            height: 24,
          ),
          onPressed: () => Get.back(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image.asset(
            //   'lib/images/ic_sol.png',
            //   width: 24,
            //   height: 24,
            // ),
            SizedBox(width: 8),
            Text(
              itemData['tokenSymbol'] ?? '主题理财',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {
              // 显示帮助信息
            },
          ),
        ],
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(
                    children: [
                      Text(
                        '收益来源',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.info_outline,
                            color: Colors.white54, size: 18),
                        onPressed: () {
                          // 显示收益来源说明
                        },
                      ),
                    ],
                  ),
                  Text(
                    itemData['tokenSymbol'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ]),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '参考年化 >',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          itemData['showApr']?.toString() ?? '',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),

            SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                '数量',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              Text(
                '可用：$availableAmount ' + itemData['TokenBuyCoin'],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ]),

            Container(
              margin: EdgeInsets.only(top: 8),
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: amountController,
                      style: TextStyle(color: Colors.white, fontSize: 24),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '1',
                        hintStyle: TextStyle(color: Colors.white54),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          amount = value;
                        });
                      },
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        amount = availableAmount;
                        amountController.text = amount;
                      });
                    },
                    child: Text(
                      '最大',
                      style: TextStyle(
                        color: Color(0xFF6A4CFF),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '可用：0 SOL',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '汇率  3%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '滑点  ≤5% ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '智能矿工费支付',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                // IconButton(
                //   icon:
                //       Icon(Icons.help_outline, color: Colors.white54, size: 18),
                //   onPressed: () {
                //     // 显示说明
                //   },
                // ),
              ],
            ),
            SizedBox(height: 16),
            // Text(
            //   '预计每日收益',
            //   style: TextStyle(
            //     color: Colors.white54,
            //     fontSize: 14,
            //   ),
            // ),
            // Text(
            //   '0 OKSOL?',
            //   style: TextStyle(
            //     color: Colors.white,
            //     fontSize: 14,
            //   ),
            // ),
            Spacer(),
            // Text(
            //   '隐藏期',
            //   style: TextStyle(
            //     color: Colors.white54,
            //     fontSize: 14,
            //   ),
            // ),
            // Text(
            //   '4-5 天',
            //   style: TextStyle(
            //     color: Colors.white,
            //     fontSize: 16,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            // SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // 处理继续操作
                  // buyFundFun();
                  bool flag = checkAndPay(
                          andPay: (double.parse(amount) * pow(10, 8)).toInt())
                      as bool;
                  if (flag) {
                    noneGasBuy();
                  }
                  // buyFundFun();
                  // noneGasBuy();
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF6A4CFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  '购买',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
