import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purse_for_evmorbtc/tools/Adapt.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../http/api.dart';
import '../../http/dio_utils.dart';
import '../../tools/WalletBalance.dart';
import '../../tools/WalletStorage.dart';
import '../../tools/constants.dart';

class MyAssetsPage extends StatefulWidget {
  const MyAssetsPage({super.key});

  @override
  State<MyAssetsPage> createState() => _MyAssetsPageState();
}

class _MyAssetsPageState extends State<MyAssetsPage> {
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
    {
      'symbol': 'USDT',
      'icon': 'lib/images/USDT.png',
      'balance': '0',
    },
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
  List mainCoins = [
    {
      'symbol': 'ETH',
      'icon': 'lib/images/ETH.png',
      'balance': '0',
    }
  ];
  List DeiCoins = [
    {
      'symbol': 'wUSD0++',
      'icon': 'lib/images/wUSD0++.png',
      'balance': '0',
    }
  ];

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
        "${Api.assetsUrl}1/$evmAddress1",
        tips: false,
        context: context,
      );

      // final res = await HttpUtils.instance.get(
      //   "${Api.assetsUrl}1/0x1234567890abcdef2",
      //   tips: false,
      //   context: context,
      // );

      if (res.code == 0) {
        setState(() {
          pointsCoins[0]["balance"] = res.data["score"];
          mainCoins[0]["balance"] = res.data["nativeToken"];
          List list = [];
          for (var i = 0; i < res.data["stableCoins"].length; i++) {
            list.add({
              'symbol': res.data["stableCoins"][i]["coin"]["tokenSymbol"],
              'icon':
                  'lib/images/${res.data["stableCoins"][i]["coin"]["tokenSymbol"]}.png',
              'balance': res.data["stableCoins"][i]["balance"],
            });
          }
          stableCoins = list;

          List list2 = [];
          for (var i = 0; i < res.data["defiCoins"].length; i++) {
            list2.add({
              'symbol': res.data["defiCoins"][i]["coin"]["tokenSymbol"],
              'icon':
                  'lib/images/${res.data["defiCoins"][i]["coin"]["tokenSymbol"]}.png',
              'balance': res.data["defiCoins"][i]["balance"],
            });
          }
          DeiCoins = list2;
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
          '我的资产',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
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
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        Spacer(),
                        Text(
                          coin['balance'],
                          style: TextStyle(
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
            // 稳定币区域
            Text(
              '稳定币',
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
                children: stableCoins.map((coin) {
                  return Padding(
                    padding: EdgeInsets.only(
                        bottom: coin != stableCoins.last ? 16 : 0),
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
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        Spacer(),
                        Text(
                          coin['balance'],
                          style: TextStyle(
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

            // 主币区域
            Text(
              '主币',
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
                children: mainCoins.map((coin) {
                  return Padding(
                    padding: EdgeInsets.only(
                        bottom: coin != mainCoins.last ? 16 : 0),
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
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        Spacer(),
                        Text(
                          coin['balance'],
                          style: TextStyle(
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
            Text(
              'Dei',
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
                children: DeiCoins.map((coin) {
                  return Padding(
                    padding:
                        EdgeInsets.only(bottom: coin != DeiCoins.last ? 16 : 0),
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
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        Spacer(),
                        Text(
                          coin['balance'],
                          style: TextStyle(
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
          ],
        ),
      ),
    );
  }
}
