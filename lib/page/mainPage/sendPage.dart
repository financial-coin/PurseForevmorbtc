import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:purse_for_evmorbtc/page/switchCoinPage.dart';
import 'package:purse_for_evmorbtc/tools/Adapt.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../tools/CurrencySelector.dart';
import '../../tools/WalletBalance.dart';
import '../../tools/WalletStorage.dart';

class SendPage extends StatefulWidget {
  const SendPage({super.key});

  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
// class SendPage extends StatelessWidget {

  String selectedCurrency = 'ETH'; // 默认选择的货币
  final List<String> currencies = ['ETH', 'BTU', 'USDT', 'USDC'];

  String? evmAddress1 = "";
  String? btcAddress1 = "";
  String address = "";
  String title = "";
  String titleIcon = "";
  String collectionAddress = "";
  String moneyCount = "";
  String evmPrikey1 = "";
  String btcWIF1 = "";
  String currentNetwork1 = "";
  String account1 = "";

  String gasFee = "0.00021541 ETH"; // 默认矿工费
  String gasFeeDescription = "5.28 GWEI"; // 默认矿工费描述
  String gasType = "一般";

  @override
  void initState() {
    super.initState();
    var currentNetwork = Get.arguments["currentNetwork"];
    var account = Get.arguments["account"];
    getPublicKey(currentNetwork, account);
    setState(() {
      currentNetwork1 = currentNetwork;
      account1 = account;

      title = (currentNetwork == "Bitcoin" ? "发送 BTC" : "发送 ETH");
      titleIcon = (currentNetwork == "Bitcoin"
          ? "lib/images/ic_Bitcoin.png"
          : "lib/images/ETH.png");
    });
  }

  getPublicKey(currentNetwork, account) async {
    final wallet = await WalletStorage.getWallet(account);
    if (wallet != null) {
      final evmAddress = wallet['evmAddress'];
      final btcAddress = wallet['btcAddress'];
      final evmPrikey = wallet['evmPrikey'];
      final btcWIF = wallet['btcWIF'];
      // ... 使用其他数据
      setState(() {
        evmAddress1 = evmAddress;
        btcAddress1 = btcAddress;
        evmPrikey1 = evmPrikey!;
        btcWIF1 = btcWIF!;
        address = (currentNetwork == "Bitcoin" ? btcAddress! : evmAddress!);
      });
    }

    // final SharedPreferences prefs = await SharedPreferences.getInstance();

    // final String? evmAddress = prefs.getString('evmAddress');
    // final String? evmPrikey = prefs.getString('evmPrikey');

    // final String? btcAddress = prefs.getString('btcAddress');
    // final String? btcWIF = prefs.getString('btcWIF');

    // setState(() {
    //   evmAddress1 = evmAddress;
    //   btcAddress1 = btcAddress;
    //   evmPrikey1 = evmPrikey!;
    //   btcWIF1 = btcWIF!;

    //   address = (currentNetwork == "Bitcoin" ? btcAddress! : evmAddress!);
    //   title = (currentNetwork == "Bitcoin" ? "发送 BTC" : "发送 ETH");
    //   titleIcon = (currentNetwork == "Bitcoin"
    //       ? "lib/images/ic_Bitcoin.png"
    //       : "lib/images/ic_Ethereum.png");
    // });
  }

// ETC 交易
  void EthTransfer() async {
    final walletBalance = WalletBalance();

    // 发送方私钥（从 Ganache 获取）
    final privateKey = evmPrikey1;
    // 接收方地址
    final toAddress = collectionAddress;

    // 发送交易
    final txHash = await walletBalance.sendTransaction(
        fromPrivateKey: privateKey,
        toAddress: toAddress,
        amount: double.parse(moneyCount), // 转账 1 ETH
        currency: selectedCurrency);

    if (txHash != null) {
      // 等待几秒让交易被确认
      await Future.delayed(Duration(seconds: 2));

      // 检查交易状态
      final success = await walletBalance.getTransactionStatus(txHash);
      if (success) {
        print('EVM 转账成功！');
        Get.snackbar(
          '转账成功！',
          '交易已提交到区块链',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        print('EVM 转账失败！');
      }
    }
  }

  // BTC 交易
  void BTCTransfer() async {
    final walletBalance = WalletBalance();

    // 发送方信息
    final fromAddress = btcAddress1; // 你的地址
    final privateKeyWIF = btcWIF1; // 需要填入对应的私钥

    // 接收方地址
    final toAddress = collectionAddress; // 目标地址

    // 先检查余额
    print('\n检查当前余额...');
    await walletBalance.checkBTCStatus(fromAddress!, true);

    try {
      // 发送交易
      print('\n开始构建交易...');
      final txHash = await walletBalance.sendBTCTransaction(
          fromAddress: fromAddress,
          privateKeyWIF: privateKeyWIF,
          toAddress: toAddress,
          amount: double.parse(moneyCount), // 转 0.00001 BTC
          isTestnet: true);

      if (txHash != null) {
        print('\n交易已广播!');
        print('交易哈希: $txHash');
        print('查看交易: https://mempool.space/testnet/tx/$txHash');
        Get.snackbar(
          '转账成功！',
          '交易已提交到区块链',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        print('\n交易广播失败，请重试');
      }
    } catch (e) {
      print('\n转账失败: $e');
    }
  }

  Transfer() async {
    if (currentNetwork1 == "Bitcoin") {
      BTCTransfer();
    } else {
      EthTransfer();
    }
  }

  // 显示矿工费配置界面
  void _showGasFeeConfig() {
    Get.dialog(
      AlertDialog(
        title: Text('矿工费配置'),
        // iconColor:,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('极快: 0.00032311 ETH'),
              subtitle: Text('7.93 GWEI  \$1.17462525'),
              onTap: () {
                setState(() {
                  gasFee = "0.00032311 ETH";
                  gasFeeDescription = "7.93 GWEI";
                  gasType = "极快";
                });
                Get.back();
              },
            ),
            ListTile(
              title: Text('快速: 0.00025849 ETH'),
              subtitle: Text('6.34 GWEI \$0.9397002'),
              onTap: () {
                setState(() {
                  gasFee = "0.00025849 ETH";
                  gasFeeDescription = "6.34 GWEI ";
                  gasType = "快速";
                });
                Get.back();
              },
            ),
            ListTile(
              title: Text('一般: 0.00021541 ETH'),
              subtitle: Text('5.28 GWEI \$0.74392933'),
              onTap: () {
                setState(() {
                  gasFee = "0.00021541 ETH";
                  gasFeeDescription = "5.28 GWEI ";
                  gasType = "一般";
                });
                Get.back();
              },
            ),
            ListTile(
              title: Text('缓慢: 0.00020464 ETH'),
              subtitle: Text('5.02 GWEI \$0.74392933'),
              onTap: () {
                setState(() {
                  gasFee = "0.00020464 ETH";
                  gasFeeDescription = "5.02 GWEI ";
                  gasType = "缓慢";
                });
                Get.back();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('关闭'),
          ),
        ],
      ),
      barrierColor: Colors.black.withOpacity(0.5),
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
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () => Get.back(),
          ),
        ),
        body: Container(
          margin: EdgeInsets.fromLTRB(Adapt.px(16), 0, Adapt.px(16), 0),
          child: Column(
            children: [
              // ETH 图标和标题
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        color: Color(0xFF6B57FF),
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        titleIcon,
                        width: 28,
                        height: 28,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 选择币种和网络的控件
                  if (currentNetwork1 != "Bitcoin")
                    const Text(
                      "选择币种",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  SizedBox(height: 20),
                  if (currentNetwork1 != "Bitcoin")
                    GestureDetector(
                      onTap: () async {
                        final result = await Get.to(
                          () => SwitchCoinPage(
                            currentAccount: selectedCurrency,
                          ),
                        );
                        if (result != null) {
                          setState(() {
                            selectedCurrency = result;
                            title = (currentNetwork1 == "Bitcoin"
                                ? "发送 BTC"
                                : "发送 ${selectedCurrency}");
                            titleIcon = (currentNetwork1 == "Bitcoin"
                                ? "lib/images/ic_Bitcoin.png"
                                : "lib/images/${selectedCurrency}.png");
                          });
                        }
                      },
                      child: Container(
                        height: Adapt.px(130),
                        padding: EdgeInsets.fromLTRB(
                            Adapt.px(16), 0, Adapt.px(16), 0),
                        margin: EdgeInsets.only(bottom: Adapt.px(12)),
                        decoration: BoxDecoration(
                          color: Color(0xFF1C1259),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                // 这里可以添加图标
                                Image.asset(
                                  'lib/images/$selectedCurrency.png', // 替换为 ETH 图标的路径
                                  width: Adapt.px(66),
                                  height: Adapt.px(66),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  selectedCurrency,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ],
                            ),
                            const Icon(Icons.arrow_forward_ios,
                                color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(height: Adapt.px(16)),
                  const Text(
                    "收款地址",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    color: Color(0xFF1C1259),
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: '收款地址',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      onChanged: (value) {
                        setState(() {
                          collectionAddress = value;
                        });
                      },
                    ),
                  ),

                  Text(
                    "发送地址:$evmAddress1",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      // fontWeight: FontWeight.w500,
                    ),
                  ),

                  SizedBox(height: 5),
                  // Text(
                  //   '很好！',
                  //   style: TextStyle(color: Colors.green, fontSize: 14),
                  // ),
                  SizedBox(height: 20),
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "转账数量",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "可用数量: 0$selectedCurrency",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ]),

                  SizedBox(height: 20),
                  Container(
                      color: Color(0xFF1C1259),
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: '发送数量',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        onChanged: (value) {
                          setState(() {
                            moneyCount = value;
                          });
                        },
                      )),
                  SizedBox(height: 20),
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "矿工费",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(children: [
                          Text(
                            "竞价交易",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ]),
                      ]),
                  // 矿工费配置框
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: _showGasFeeConfig,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF1C1259),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey, width: 1.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(
                          //   '矿工费',
                          //   style: TextStyle(color: Colors.white, fontSize: 18),
                          // ),
                          Text(
                            '$gasFee ($gasType)',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Row(children: [
                            Text(
                              '$gasFeeDescription',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 16,
                            )
                          ]),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Get.dialog(
                        AlertDialog(
                          backgroundColor: Color(0xFF1C1259),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text(
                            '确认发送',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '您确定要发送该笔交易吗？',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                '请确认收款地址和发送数量无误',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: Text(
                                '取消',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Transfer();
                                Get.back();
                                // 执行发送逻辑
                                print('确认发送交易');
                              },
                              child: const Text(
                                '确定',
                                style: TextStyle(
                                  color: Color(0xFF6A4CFF),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        barrierColor: Colors.black.withOpacity(0.5),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF6A4CFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: Size(400, 50),
                    ),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      child: Text(
                        '发送',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
