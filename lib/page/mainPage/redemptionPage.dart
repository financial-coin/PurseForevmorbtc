import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purse_for_evmorbtc/tools/Adapt.dart';

import '../../tools/WalletTockenBlance.dart';

class RedemptionPage extends StatefulWidget {
  const RedemptionPage({Key? key}) : super(key: key);

  @override
  _RedemptionPageState createState() => _RedemptionPageState();
}

class _RedemptionPageState extends State<RedemptionPage> {
  String amount = '';
  double availableAmount = 2513.02;
  double totalAmount = 2515.416222;
  String selectedCurrency = 'USDT';
  late final Map<String, dynamic> itemData;

  @override
  void initState() {
    super.initState();
    itemData = Get.arguments["item"];
    setState(() {
      selectedCurrency = itemData['TokenBuyCoin'];
    });
    getFundAccount();
  }

  getFundAccount() async {
    try {
      final result = await WalletTockenBlance().getFundAccount(
        "0x63cD86B755eD1000BeE1a7C750fA7D57262E100f", // 基金合约地址
        "0x5e96dc0c4a3c0cdeea7f8d45451d8804a0659349", // 用户地址
      );

      print('基金份额: ${result['shares']}');
      print('当前价值: ${result['value']}');
      print('投资成本: ${result['cost']}');

      setState(() {
        totalAmount = double.parse(result['shares'].toString());
        availableAmount = double.parse(result['value'].toString());
      });
    } catch (e) {
      print('查询失败: $e');
    }
  }

  // 添加币种列表
  final List<Map<String, dynamic>> currencies = [
    {
      'name': 'USDT',
      'icon': 'lib/images/USDT.png',
      'balance': '2515.416222',
      'invested': '2513.02',
    },
    {
      'name': 'USDC',
      'icon': 'lib/images/USDC.png',
      'balance': '1000.00',
      'invested': '998.50',
    },
  ];

  // 显示币种选择器
  void _showCurrencyPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1C1259),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: currencies.map((currency) {
            return ListTile(
              leading: Image.asset(
                currency['icon'],
                width: 24,
                height: 24,
              ),
              title: Text(
                currency['name'],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              trailing: selectedCurrency == currency['name']
                  ? Icon(Icons.check_circle, color: Color(0xFF6A4CFF))
                  : null,
              onTap: () {
                setState(() {
                  selectedCurrency = currency['name'];
                  totalAmount = double.parse(currency['balance']);
                  availableAmount = double.parse(currency['invested']);
                  amount = '';
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _onNumberPressed(String value) {
    setState(() {
      if (value == '.' && amount.contains('.')) return;
      if (value == '⌫') {
        if (amount.isNotEmpty) {
          amount = amount.substring(0, amount.length - 1);
        }
      } else {
        amount += value;
      }
    });
  }

  void _setPercentage(double percentage) {
    setState(() {
      amount = (availableAmount * percentage).toStringAsFixed(0);
    });
  }

//赎回
  redeemFundFun() async {
    //   redeemFund(
    //   String privateKey,
    //   String fundAddress, // 基金地址
    //   String toAddress, // 接收代币的地址
    //   BigInt shares, // 赎回的份额
    // )
    // final result = WalletTockenBlance().redeemFund(
    //   "0x896465cb9be7d4da1b06d5b9ef1dc0715527dc4d1bb18dd149318c5cf4ea0af9", // 基金合约地址
    //   "0x63cD86B755eD1000BeE1a7C750fA7D57262E100f", // 基金合约地址
    //   "0x5e96dc0c4a3c0cdeea7f8d45451d8804a0659349", // 用户地址
    //   BigInt.from(int.parse(amount)), // 赎回的份额
    // );

    // 确保这个方法是异步的

    if (int.parse(amount) > 0) {
      try {
        print('赎回份额: $amount');

        final result = await WalletTockenBlance().redeemFund(
          "0x896465cb9be7d4da1b06d5b9ef1dc0715527dc4d1bb18dd149318c5cf4ea0af9", // 私钥
          "0x63cD86B755eD1000BeE1a7C750fA7D57262E100f", // 基金合约地址
          "0x5e96dc0c4a3c0cdeea7f8d45451d8804a0659349", // 用户地址
          BigInt.parse(amount), // 赎回的份额
        );
        print('赎回成功: $result');
        Get.back();
      } catch (e) {
        print('赎回失败: $e');
      }
    } else {
      print('赎回份额不能为0');
      Get.snackbar(
        '赎回份额错误',
        '赎回份额不能为0或者是小数',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF110A3A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image.asset(
            //   'lib/images/ic_usdt.png',
            //   width: 24,
            //   height: 24,
            // ),
            // SizedBox(width: 8),
            Text(
              '赎回 $selectedCurrency',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
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
                    SizedBox(width: Adapt.px(16)),
                    Text(
                      "赎回 USDT",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Adapt.px(16)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        // 添加 Expanded 组件
                        child: Text(
                      '$totalAmount USDT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                    Text(
                      '■ USDT',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '在投资产：$availableAmount $selectedCurrency',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  '得到',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    // onTap: _showCurrencyPicker,
                    child: Row(
                      children: [
                        // Image.asset(
                        //   'lib/images/$selectedCurrency.png',
                        //   width: 24,
                        //   height: 24,
                        // ),
                        SizedBox(width: Adapt.px(20)),
                        Expanded(
                            // 添加 Expanded 组件
                            child: Text(
                          amount.isEmpty ? '0' : amount,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        )),
                        Text(
                          ' $selectedCurrency',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 百分比按钮
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPercentButton('25%', 0.25),
                _buildPercentButton('50%', 0.5),
                _buildPercentButton('Max', 1.0),
              ],
            ),
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(Adapt.px(32), 0, 0, 0),
                child: Column(
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
              )
            ],
          ),
          Spacer(),
          // 数字键盘
          Container(
            color: Colors.black12,
            child: Column(
              children: [
                _buildNumberRow(['1', '2', '3']),
                _buildNumberRow(['4', '5', '6']),
                _buildNumberRow(['7', '8', '9']),
                _buildNumberRow(['0', '⌫']),
              ],
            ),
          ),
          // 下一步按钮
          Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // 处理下一步
                  // Get.toNamed('/RedemptionNextPage');

                  redeemFundFun();
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF6A4CFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text('提交'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPercentButton(String text, double percentage) {
    return TextButton(
      onPressed: () => _setPercentage(percentage),
      style: TextButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildNumberRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((number) {
        return Expanded(
          child: TextButton(
            onPressed: () => _onNumberPressed(number),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 20),
            ),
            child: Text(
              number,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
