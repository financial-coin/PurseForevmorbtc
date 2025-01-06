import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purse_for_evmorbtc/tools/Adapt.dart';
import 'package:purse_for_evmorbtc/tools/WalletStorage.dart';

class WalletManagementMicPage extends StatefulWidget {
  @override
  _WalletManagementMicPageState createState() =>
      _WalletManagementMicPageState();
}

class _WalletManagementMicPageState extends State<WalletManagementMicPage> {
  bool isPrivateKey = true; // true为私钥模式，false为助记词模式
  String evmPrikey = '';
  String btcPrikey = '';
  String mnemonic = '';
  bool isCopied = false;
  bool isContentVisible = false; // 添加内容是否可见的状态

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    final arguments = Get.arguments;
    if (arguments != null) {
      final wallet = await WalletStorage.getWallet(arguments['account']);
      if (wallet != null) {
        setState(() {
          evmPrikey = wallet['evmPrikey'] ?? '';
          btcPrikey = wallet['btcPrikey'] ?? '';
          mnemonic = wallet['mnemonic'] ?? '';
        });
      }
    }
  }

  // 构建遮罩内容
  Widget _buildMaskedContent(Widget content, double height) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF1C1259),
            borderRadius: BorderRadius.circular(12),
          ),
          child: isContentVisible
              ? content
              : Container(
                  height: height,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          color: Colors.white,
                          size: 32,
                        ),
                        SizedBox(height: 8),
                        Text(
                          '点击此处显示私钥',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        if (!isContentVisible)
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    isContentVisible = true;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(),
              ),
            ),
          ),
      ],
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
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          '导出助记词',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.help_outline, color: Colors.white),
        //     onPressed: () {
        //       // 帮助说明
        //     },
        //   ),
        // ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF110A3A),
              Color(0xFF2C1F68),
            ],
          ),
        ),
        child: Column(
          children: [
            // 顶部切换按钮
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Color(0xFF1C1259),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isPrivateKey = true;
                          isContentVisible = false;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isPrivateKey
                              ? Color(0xFF6A4CFF)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          '助记词',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: isPrivateKey
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isPrivateKey = false;
                          isContentVisible = false;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !isPrivateKey
                              ? Color(0xFF6A4CFF)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          '二维码',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: !isPrivateKey
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 内容区域
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (isPrivateKey) ...[
                      _buildMaskedContent(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "助记词:",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                mnemonic,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                          100),
                    ],
                    if (!isPrivateKey) ...[
                      SizedBox(height: Adapt.px(20)),
                      _buildMaskedContent(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "助记词:",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(height: Adapt.px(10)),
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
                                  data: mnemonic,
                                  color: Colors.black,
                                  backgroundColor: Colors.white,
                                ),
                              ),

                              SizedBox(height: Adapt.px(20)),
                            ],
                          ),
                          200),
                    ],
                  ],
                ),
              ),
            ),
            //

            // 底部复制按钮
            Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  onPressed: () {
                    if (isContentVisible) {
                      Clipboard.setData(
                        ClipboardData(
                          text: mnemonic,
                        ),
                      );
                      setState(() => isCopied = true);
                      Get.snackbar(
                        '复制成功',
                        '内容已复制到剪贴板',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: isContentVisible
                        ? Color(0xFF6A4CFF)
                        : Color(0xFF6A4CFF).withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    '复制助记词',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
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
