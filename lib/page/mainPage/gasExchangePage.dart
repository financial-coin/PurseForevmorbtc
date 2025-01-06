import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purse_for_evmorbtc/tools/Adapt.dart';

class GasExchangePage extends StatefulWidget {
  const GasExchangePage({Key? key}) : super(key: key);

  @override
  _GasExchangePageState createState() => _GasExchangePageState();
}

class _GasExchangePageState extends State<GasExchangePage> {
  String payAmount = '';
  String receiveAddress = '';
  double ethReceive = 0.15; // 示例数值
  String selectedCurrency = 'BTU';
  String selectedNetwork = 'ETH';

  // 添加币种列表
  final List<String> currencies = ['BTU', 'USDT', 'ETH', 'BTC'];
  final List<String> networks = ['ETH', 'BSC', 'TRON', 'BTC'];

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
              title: Text(
                currency,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              trailing: selectedCurrency == currency
                  ? Icon(Icons.check, color: Color(0xFF6A4CFF))
                  : null,
              onTap: () {
                setState(() {
                  selectedCurrency = currency;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  // 显示网络选择器
  void _showNetworkPicker() {
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
          children: networks.map((network) {
            return ListTile(
              title: Text(
                network,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              trailing: selectedNetwork == network
                  ? Icon(Icons.check, color: Color(0xFF6A4CFF))
                  : null,
              onTap: () {
                setState(() {
                  selectedNetwork = network;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
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
        title: Text(
          'gas费兑换',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(Adapt.px(32)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '支付',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: '请输入支付金额',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                      onChanged: (value) {
                        setState(() {
                          payAmount = value;
                        });
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: _showCurrencyPicker,
                      child: Row(
                        children: [
                          Text(
                            selectedCurrency,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                ],
              ),
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '接收',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '您将收到${ethReceive} ETH',
                  style: TextStyle(
                    color: Color(0xFF6A4CFF),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: _showNetworkPicker,
                child: Row(
                  children: [
                    Text(
                      '切换网络',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '请输入接收的地址',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                onChanged: (value) {
                  setState(() {
                    receiveAddress = value;
                  });
                },
              ),
            ),
            SizedBox(height: 24),
            Center(
              child: Text(
                '1usdt=0.00023ETH',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 16,
                ),
              ),
            ),
            Spacer(),
            Container(
              width: double.infinity,
              height: 50,
              margin: EdgeInsets.only(bottom: Adapt.px(32)),
              child: ElevatedButton(
                onPressed: () {
                  // 处理提交交易逻辑
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF6A4CFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  '提交交易',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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
