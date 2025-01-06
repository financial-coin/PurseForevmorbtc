import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purse_for_evmorbtc/tools/Adapt.dart';

class AddWalletPage extends StatefulWidget {
  const AddWalletPage({
    Key? key,
  }) : super(key: key);

  @override
  _AddWalletPageState createState() => _AddWalletPageState();
}

class _AddWalletPageState extends State<AddWalletPage> {
  @override
  void initState() {
    super.initState();
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
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 钱包图标
          Center(
            child: Image.asset(
              'lib/images/img_bag.png',
              width: Adapt.px(500),
              height: Adapt.px(500),
            ),
          ),
          SizedBox(height: Adapt.px(20)),
          // 欢迎文本
          Text(
            '欢迎来到 Wallet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: Adapt.px(100)),
          // 创建钱包按钮
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Adapt.px(80)),
            child: ElevatedButton(
              onPressed: () {
                Get.toNamed('/CreateWalletForMnemonicN');
              },
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF6A4CFF),
                minimumSize: Size(double.infinity, Adapt.px(180)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '创建钱包',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '我没有钱包',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: Adapt.px(48)),
          // 导入钱包按钮
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Adapt.px(80)),
            child: OutlinedButton(
              onPressed: () {
                Get.toNamed('/MySelfWalletN');
              },
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, Adapt.px(180)),
                side: BorderSide(color: Color(0xFF6A4CFF)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '导入钱包',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '支持任意钱包的助记词或私钥导入',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
