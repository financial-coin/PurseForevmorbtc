import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purse_for_evmorbtc/tools/Adapt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../http/api.dart';
import '../../http/dio_utils.dart';
import '../../tools/WalletBalance.dart';
import '../../tools/WalletStorage.dart';
import '../../tools/constants.dart';

class MyAssetsBTCPage extends StatefulWidget {
  const MyAssetsBTCPage({super.key});

  @override
  State<MyAssetsBTCPage> createState() => _MyAssetsBTCPageState();
}

class _MyAssetsBTCPageState extends State<MyAssetsBTCPage> {
  String? evmAddress1 = "";
  String? btcAddress1 = "";
  double btcBalance = 0;
  double evmBalance = 0;

  List pointsCoins = [
    {
      'symbol': '积分',
      'icon': 'lib/images/integral.png',
      'balance': '0',
    }
  ];

  List stableCoins = [
    // {
    //   'symbol': 'USDT',
    //   'icon': 'lib/images/USDT.png',
    //   'balance': '0',
    // },
    // {
    //   'symbol': 'USDC',
    //   'icon': 'lib/images/USDC.png',
    //   'balance': '0.0',
    // },
    // {
    //   'symbol': 'HKDA',
    //   'icon': 'lib/images/WETH.png',
    //   'balance': '0.0',
    // },
  ];
  // List mainCoins = [
  //   {
  //     'symbol': 'ETH',
  //     'icon': 'lib/images/ETH.png',
  //     'balance': '0',
  //   }
  // ];
  // List DeiCoins = [
  //   {
  //     'symbol': 'wUSD0++',
  //     'icon': 'lib/images/wUSD0++.png',
  //     'balance': '0',
  //   }
  // ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var account = Get.arguments["account"];
    getPublicKey(account);
  }

  Future<void> getBalanceD() async {
    try {
      final res = await HttpUtils.instance.get(
        "${Api.btcAssetsUrl}1/$btcAddress1",
        tips: false,
        context: context,
      );

      // final res = await HttpUtils.instance.get(
      //   "${Api.btcAssetsUrl}1/bc1ql49ydapnjafl5t2cp9zqpjwe6pdgmxy98859v2",
      //   tips: false,
      //   context: context,
      // );

      if (res.code == 0) {
        setState(() {
          pointsCoins[0]["balance"] = res.data["score"];
          // mainCoins[0]["balance"] = res.data["nativeToken"];
          List list = [];
          for (var i = 0; i < res.data["utxo"].length; i++) {
            list.add({
              'txid': res.data["utxo"][i]["txid"],
              // 'time': res.data["utxo"][i]["time"],
              'unspentAmount': res.data["utxo"][i]["unspentAmount"],
              'address': res.data["utxo"][i]["address"],
            });
          }
          stableCoins = list;

          // List list2 = [];
          // for (var i = 0; i < res.data["defiCoins"].length; i++) {
          //   list2.add({
          //     'symbol': res.data["defiCoins"][i]["coin"]["tokenSymbol"],
          //     'icon':
          //         'lib/images/${res.data["defiCoins"][i]["coin"]["tokenSymbol"]}.png',
          //     'balance': res.data["defiCoins"][i]["balance"],
          //   });
          // }
          // DeiCoins = list2;
        });
      }
    } catch (e) {
      print("加载数据错误: $e");
    }
  }

  getPublicKey(account) async {
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
      });
      getBalanceD();
    }

    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    // final String? evmAddress = prefs.getString('evmAddress');
    // final String? btcAddress = prefs.getString('btcAddress');

    // setState(() {
    //   evmAddress1 = evmAddress;
    //   btcAddress1 = btcAddress;
    // });
  }

  getBalance() async {
    print('----> 查询');
    // double BalanceValue = 0;

    final walletBalance = WalletBalance();
    // if (currentNetwork == "Bitcoin") {
    final btcBalance1 =
        await walletBalance.getBTCBalance(btcAddress1!, isProduction);
    print('BTC 余额: $btcBalance  BTC');
    // BalanceValue = btcBalance;

    // } else {
    final evmBalance1 =
        await walletBalance.getEVMBalance(evmAddress1!); // 使用 Ganache 中的地址
    print('EVM 余额: $evmBalance ETH');
    stableCoins[1]["balance"] = btcBalance1.toString();
    stableCoins[2]["balance"] = evmBalance1.toString();
    List list = jsonDecode(jsonEncode(stableCoins));

    setState(() {
      stableCoins = list;
    });
    // BalanceValue = evmBalance;

    // }
    // return BalanceValue.toString();
  }

//   String formatTimestamp(int timestamp) {
//     // 时间戳是以秒为单位，需要转换为毫秒
//     DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
//     // 格式化日期
//     return "${dateTime.year}-${_addZero(dateTime.month)}-${_addZero(dateTime.day)}";
//   }

// // 补零函数
//   String _addZero(int number) {
//     return number < 10 ? "0$number" : "$number";
//   }

  String formatString(String input) {
    if (input.length <= 10) {
      return input; // 如果字符串长度小于等于10，直接返回
    }
    String start = input.substring(0, 10); // 获取前6位
    String end = input.substring(input.length - 10); // 获取后4位
    return '$start...$end'; // 拼接结果
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
        title: const Text(
          '我的资产',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '奖励',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF1C1259),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: pointsCoins.map((coin) {
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: coin != pointsCoins.last ? 16 : 0),
                      child: Row(
                        children: [
                          Image.asset(
                            coin['icon'],
                            width: 24,
                            height: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            coin['symbol'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          Spacer(),
                          Text(
                            coin['balance'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              SizedBox(height: 24),
              // UTXO 区域
              if (stableCoins.isNotEmpty)
                const Text(
                  'UTXO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              SizedBox(height: 12),
              if (stableCoins.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF1C1259),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: stableCoins.map((coin) {
                      return Padding(
                        padding: EdgeInsets.only(
                            bottom: coin != stableCoins.last ? 16 : 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "交易ID：${formatString(coin['txid'])}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  icon: const Icon(
                                    Icons.copy,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  onPressed: () {
                                    Clipboard.setData(
                                        ClipboardData(text: coin['txid']));
                                    Get.snackbar(
                                      '复制成功',
                                      '交易ID已复制到剪贴板',
                                      backgroundColor: Colors.green,
                                      colorText: Colors.white,
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: Adapt.px(10)),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "地址：${formatString(coin['address'])}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  icon: const Icon(
                                    Icons.copy,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  onPressed: () {
                                    Clipboard.setData(
                                        ClipboardData(text: coin['address']));
                                    Get.snackbar(
                                      '复制成功',
                                      '地址已复制到剪贴板',
                                      backgroundColor: Colors.green,
                                      colorText: Colors.white,
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: Adapt.px(10)),
                            Text(
                              "余额：${coin['unspentAmount']}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: Adapt.px(8)),
                            Container(
                              width: double.infinity,
                              height: 1,
                              color: Colors.grey,
                            )
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
