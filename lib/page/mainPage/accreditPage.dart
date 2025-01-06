import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purse_for_evmorbtc/tools/Adapt.dart';

import '../../tools/WalletTockenBlance.dart';

class AccreditPage extends StatefulWidget {
  const AccreditPage({Key? key}) : super(key: key);

  @override
  _AccreditPageState createState() => _AccreditPageState();
}

class _AccreditPageState extends State<AccreditPage> {
  // final double amount = 2515.416222;
  final String network = 'BNB Chain';
  final double vUSDTAmount = 101190.932153;
  late final Map<String, dynamic> itemData;
  late final String availableAmount;
  TextEditingController amountController = TextEditingController();
  String amount = '';
  @override
  void initState() {
    super.initState();
    // print('AccreditPage initState');
    itemData = Get.arguments["item"];
    availableAmount = Get.arguments["availableAmount"];
    amountController.text = availableAmount;
    amount = availableAmount;
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
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 顶部卡片
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF1C1259),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'lib/images/USDT.png',
                      width: 24,
                      height: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '授权 ${itemData['TokenBuyCoin']}',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  '可用: $availableAmount ${itemData['TokenBuyCoin']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // const Text(
                //   '2,513.02 USDT',
                //   style: TextStyle(
                //     color: Colors.white70,
                //     fontSize: 14,
                //   ),
                // ),

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
              ],
            ),
          ),

          Spacer(),
          // 底部按钮
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                // 处理授权 vUSDT
                approveTockenCoin();
              },
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF6A4CFF),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                '授权 vUSDT',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //授权    -----     精度需要确认
  void approveTockenCoin() async {
    try {
      final txHash = await WalletTockenBlance().approveToken(
          "0x5e96dc0c4a3c0cdeea7f8d45451d8804a0659349",
          "0x896465cb9be7d4da1b06d5b9ef1dc0715527dc4d1bb18dd149318c5cf4ea0af9",
          BigInt.from(double.parse(amount) * pow(10, 8)) // 授权金额
          );
      print('授权成功，交易哈希: $txHash');
      Get.back();
    } catch (e) {
      print('授权失败: $e');
    }
  }
}
