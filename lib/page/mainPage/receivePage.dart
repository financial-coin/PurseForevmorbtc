import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purse_for_evmorbtc/tools/Adapt.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../tools/WalletStorage.dart';
import '../switchCoinPage.dart';

class ReceivePage extends StatefulWidget {
  const ReceivePage({super.key});

  @override
  State<ReceivePage> createState() => _ReceivePageState();
}

class _ReceivePageState extends State<ReceivePage> {
  String? evmAddress1 = "";
  String? btcAddress1 = "";
  String address = "";
  String title = "";
  String titleIcon = "lib/images/ETH.png";
  String nameCoin = "";
  String selectedCurrency = 'ETH'; // 默认选择的货币
  @override
  void initState() {
    super.initState();
    var currentNetwork = Get.arguments["currentNetwork"];
    var account = Get.arguments["account"];
    print(currentNetwork);
    print(account);
    getPublicKey(currentNetwork, account);
  }

  getPublicKey(currentNetwork, account) async {
    var selectedWallet = Get.arguments["selectedWallet"];
    final wallet = await WalletStorage.getWallet(account);
    if (wallet != null) {
      final evmAddress = wallet['evmAddress'];
      final btcAddress = wallet['btcAddress'];
      // ... 使用其他数据
      setState(() {
        evmAddress1 = evmAddress;
        btcAddress1 = btcAddress;

        address = (currentNetwork == "Bitcoin" ? btcAddress! : evmAddress!);
        title = (currentNetwork == "Bitcoin" ? "收款 BTC" : "收款 $selectedWallet");
        titleIcon = (currentNetwork == "Bitcoin"
            ? "lib/images/ic_Bitcoin.png"
            : "lib/images/$selectedWallet.png");
        nameCoin = (currentNetwork == "Bitcoin" ? "BTC" : "EVM");
      });
    }

    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    // final String? evmAddress = prefs.getString('evmAddress');
    // final String? btcAddress = prefs.getString('btcAddress');

    // setState(() {
    //   evmAddress1 = evmAddress;
    //   btcAddress1 = btcAddress;

    //   address = (currentNetwork == "Bitcoin" ? btcAddress! : evmAddress!);
    //   title = (currentNetwork == "Bitcoin" ? "收款 BTC" : "收款 ETH");
    //   titleIcon = (currentNetwork == "Bitcoin"
    //       ? "lib/images/ic_Bitcoin.png"
    //       : "lib/images/ic_Ethereum.png");
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF110A3A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // ETH 图标和标题
          Center(
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Color(0xFF6B57FF),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    titleIcon,
                    width: 32,
                    height: 32,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '扫描二维码，向我支付',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 40),

          // 二维码
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: EdgeInsets.all(16),
            child: BarcodeWidget(
              barcode: Barcode.qrCode(),
              data: address,
              color: Colors.black,
              backgroundColor: Colors.white,
            ),
          ),

          SizedBox(height: 40),

          // 地址显示和复制按钮
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    address,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, Adapt.px(40), 0, 0),
                  child: IconButton(
                    icon: Icon(Icons.copy, color: Colors.white),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: address));
                      Get.snackbar(
                        '复制成功',
                        '地址已复制到剪贴板',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    constraints: BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // 提示文本
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.white.withOpacity(0.6),
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  '仅支持发送$nameCoin资产到此地址',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
