import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:purse_for_evmorbtc/tools/Adapt.dart';
import 'package:get/get.dart';

class FirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF110A3A), // 背景颜色
          image: DecorationImage(
            image: AssetImage('lib/images/firstBG.png'), // 背景图片
            fit: BoxFit.contain, // 图片填充方式
            alignment: Alignment.topCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                '管理您的\nDeFi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: Adapt.px(20)),
              ElevatedButton(
                onPressed: () {
                  // 创建新钱包的逻辑
                  Get.toNamed('/CreateWalletForMnemonic',
                      arguments: {"data": 1});
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF6A4CFF), // 按钮颜色
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  child: Text(
                    '创建新钱包',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: Adapt.px(10)),
              TextButton(
                onPressed: () {
                  // 已有钱包的逻辑
                  Get.toNamed('/MySelfWallet', arguments: {"data": 1});
                },
                child: const Text(
                  '我已有钱包',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    decoration: TextDecoration.underline, // 添加下划线
                  ),
                ),
              ),
              SizedBox(height: Adapt.px(230)),
            ],
          ),
        ),
      ),
    );
  }
}
