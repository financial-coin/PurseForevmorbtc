import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/network_controller.dart';
import '../../http/dio_utils.dart';
import '../../tools/WalletStorage.dart';
import 'package:http/http.dart' as http;

import '../../http/api.dart';
// import 'package:youwallet/model/wallet.dart';
// import 'package:provider/provider.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  // String _platformVersion = 'Unknown';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    countDown();

    // HttpUtils.setBaseUrl();
  }

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
            children: const [],
          ),
        ),
      ),
    );
  }

  // 倒计时
  Future<void> countDown() async {
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.setString('passWord', "Chen89410yao");

    var _duration = new Duration(seconds: 2);
    new Future.delayed(_duration, go2HomePage);
  }

  // 获取钱包数据
  Future<bool> getWallets() async {
    bool isEmpty = false;
    final wallets = await WalletStorage.getWallets();
    if (wallets.isEmpty) {
      isEmpty = true;
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final lastAccount = prefs.getString('lastAccount');
    if (lastAccount != null) {
      final NetworkController networkController = Get.find<NetworkController>();
      networkController.updateAccount(lastAccount);

      // 获取钱包数据
      final wallet = await WalletStorage.getWallet(lastAccount);
      if (wallet != null) {
        final evmAddress = wallet['evmAddress'];
        final btcAddress = wallet['btcAddress'];
        if (networkController.network == "Bitcoin") {
          await CreateB(btcAddress);
        } else {
          await CreateE(evmAddress);
        }
      }
    }
    return isEmpty;
  }

  Future<void> CreateE(evmAddress) async {
    try {
      var headers = {'Content-Type': 'application/json'};
      var request =
          http.Request('POST', Uri.parse('${Api.baseUrl}${Api.createUrl}'));
      request.body = json.encode(
          {"address": evmAddress, "chainId": "1", "chainName": "Ethereum"});
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      print('${Api.baseUrl}${Api.createUrl}');
      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
      } else {
        print(response.reasonPhrase);
      }
    } catch (e) {
      print("加载数据错误: $e");
    }
  }

  Future<void> CreateB(btcAddress) async {
    try {
      var headers = {'Content-Type': 'application/json'};
      var request =
          http.Request('POST', Uri.parse('${Api.baseUrl}${Api.createUrl}'));
      request.body = json.encode(
          {"address": btcAddress, "chainId": "1", "chainName": "Ethereum"});
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      print('${Api.baseUrl}${Api.createUrl}');

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
      } else {
        print(response.reasonPhrase);
      }
      // final res = await HttpUtils.instance.post(
      //   Api.createUrl,
      //   params: {"address": btcAddress, "chainId": "1", "chainName": "Bitcoin"},
      //   tips: false,
      //   context: context,
      // );

      // if (res.code == 0) {
      //   // setState(() {
      //   //   // BalanceD = res.data.toString();
      //   // });
      // }
    } catch (e) {
      print("加载数据错误: $e");
    }
  }

  // 前往首页
  // 如果用户在本地还没有钱包，则跳转钱包新建页面
  void go2HomePage() async {
    // List wallets = Provider.of<Wallet>(context).items;
    // if (wallets.length == 0) {
    //   Navigator.pushReplacementNamed(context, 'wallet_guide');
    // } else {
    //   Navigator.pushReplacementNamed(context, '/');
    // }
    if (await getWallets()) {
      Get.toNamed('/FirstPage', arguments: {"data": 1});
    } else {
      Get.toNamed('/MainPage', arguments: {"data": 1});
    }
    // Get.toNamed('/Login', arguments: {"data": 1});
  }
}
