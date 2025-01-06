import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purse_for_evmorbtc/tools/Adapt.dart';

class ExchangePage extends StatefulWidget {
  const ExchangePage({Key? key}) : super(key: key);

  @override
  _ExchangePageState createState() => _ExchangePageState();
}

class _ExchangePageState extends State<ExchangePage> {
  String fromAmount = '1222';
  String toAmount = '3255.31409791';
  String fromCurrency = 'USDT';
  String toCurrency = 'BWB';
  String fromNetwork = 'Ethereum';
  String toNetwork = 'Solana';
  double gasAmount = 0.00;

  final TextEditingController fromAmountController =
      TextEditingController(text: '1222');
  final TextEditingController toAmountController =
      TextEditingController(text: '3255.31409791');

  // 添加货币列表
  final List<Map<String, dynamic>> currencies = [
    {
      'name': 'USDT',
      'network': 'Ethereum',
      'icon': 'lib/images/USDT.png',
    },
    {
      'name': 'BWB',
      'network': 'Solana',
      'icon': 'lib/images/BWB.png',
    },
    {
      'name': 'ETH',
      'network': 'Ethereum',
      'icon': 'lib/images/ETH.png',
    },
  ];

  // 显示货币选择器
  void _showCurrencyPicker(bool isFrom) {
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
                width: 32,
                height: 32,
              ),
              title: Text(
                currency['name'],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                currency['network'],
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              trailing: (isFrom ? fromCurrency : toCurrency) == currency['name']
                  ? Icon(Icons.check_circle, color: Color(0xFF6A4CFF))
                  : null,
              onTap: () {
                setState(() {
                  if (isFrom) {
                    fromCurrency = currency['name'];
                    fromNetwork = currency['network'];
                  } else {
                    toCurrency = currency['name'];
                    toNetwork = currency['network'];
                  }
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  // 修改代币选择区域为可点击
  Widget _buildCurrencySelector(bool isFrom) {
    return GestureDetector(
      onTap: () => _showCurrencyPicker(isFrom),
      child: Row(
        children: [
          Text(
            isFrom ? fromCurrency : toCurrency,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Icon(Icons.keyboard_arrow_down, color: Colors.white),
        ],
      ),
    );
  }

  // 在 State 类中添加交换方法
  void _swapCurrencies() {
    setState(() {
      // 交换币种
      final tempCurrency = fromCurrency;
      fromCurrency = toCurrency;
      toCurrency = tempCurrency;

      // 交换网络
      final tempNetwork = fromNetwork;
      fromNetwork = toNetwork;
      toNetwork = tempNetwork;

      // 交换金额
      final tempAmount = fromAmountController.text;
      fromAmountController.text = toAmountController.text;
      toAmountController.text = tempAmount;

      // 更新状态变量
      fromAmount = fromAmountController.text;
      toAmount = toAmountController.text;
    });
  }

  // 在 State 类中添加状态变量
  bool get canSubmit => fromAmount.isNotEmpty && toAmount.isNotEmpty;

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
        title: Text(
          '兑换',
          style: TextStyle(color: Colors.white),
        ),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.history, color: Colors.white),
        //     onPressed: () {},
        //   ),
        // ],
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // 兑换卡片
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF1C1259),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // 支付代币
                  Row(
                    children: [
                      Image.asset(
                        'lib/images/$fromCurrency.png',
                        width: Adapt.px(80),
                        height: Adapt.px(80),
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCurrencySelector(true),
                          Text(
                            fromNetwork,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 120,
                            child: TextField(
                              controller: fromAmountController,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.right,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  fromAmount = value;
                                  // 这里可以添加计算兑换金额的逻辑
                                });
                              },
                            ),
                          ),
                          Text(
                            '\$$fromAmount',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // SizedBox(height: Adapt.px(16)),
                  // 添加固定高度的间距
                  SizedBox(height: Adapt.px(10)),

                  // 兑换箭头
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.swap_vert, color: Colors.white),
                      onPressed: _swapCurrencies, // 使用交换方法
                    ),
                  ),

                  SizedBox(height: Adapt.px(10)),

                  // 接收代币
                  Row(
                    children: [
                      Image.asset(
                        'lib/images/$toCurrency.png',
                        width: Adapt.px(80),
                        height: Adapt.px(80),
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCurrencySelector(false),
                          Text(
                            toNetwork,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 120,
                            child: TextField(
                              controller: toAmountController,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.right,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  toAmount = value;
                                  // 这里可以添加计算兑换金额的逻辑
                                });
                              },
                            ),
                          ),
                          Text(
                            '\$1211.2443',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Gas费用提示
            GestureDetector(
              onTap: () {
                Get.toNamed('/GasExchangePage');
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 16),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF1C1259),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_gas_station,
                          color: Color.fromARGB(255, 73, 173, 109),
                          size: 25,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '借 Gas 服务',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                    Text(
                      '通过借 GAS 服务支付本次交易的 Gas麦',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

            Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '1 BWB = 0.37208 USDT',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.change_circle_outlined,
                    color: Colors.white,
                    size: 25,
                  ),
                ]),

            Spacer(),

            // 底部按钮
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: canSubmit
                    ? () {
                        // 处理兑换逻辑
                        Get.dialog(
                          AlertDialog(
                            backgroundColor: Color(0xFF1C1259),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: Text(
                              '确认兑换',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Text(
                              '确定要将 $fromAmount $fromCurrency\n兑换为 $toAmount $toCurrency？',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: Text(
                                  '取消',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Get.back();
                                  // 执行兑换操作
                                  Get.snackbar(
                                    '兑换成功',
                                    '交易已提交',
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                },
                                child: Text(
                                  '确定',
                                  style: TextStyle(
                                    color: Color(0xFF6A4CFF),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    : null, // 当不可提交时禁用按钮
                style: ElevatedButton.styleFrom(
                  primary: canSubmit
                      ? Color(0xFF6A4CFF)
                      : Colors.purple.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  canSubmit ? '确认兑换' : 'USDT 余额不足',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            // 底部信息
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  _buildInfoRow('滑点', '自动滑点 (3.0%)', true),
                  _buildInfoRow('价格影响', '<0.88%', true),
                  _buildInfoRow('收款地址', 'ESrbNO ARGB', true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool hasArrow) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(width: 4),
              Icon(Icons.info_outline, color: Colors.white70, size: 16),
            ],
          ),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(color: Colors.white),
              ),
              if (hasArrow) Icon(Icons.chevron_right, color: Colors.white70),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    fromAmountController.dispose();
    toAmountController.dispose();
    super.dispose();
  }
}
