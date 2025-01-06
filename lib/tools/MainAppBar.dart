import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:purse_for_evmorbtc/tools/Adapt.dart';
import 'package:get/get.dart';
import 'package:purse_for_evmorbtc/page/NetworkSelectPage.dart';
import 'package:purse_for_evmorbtc/controllers/network_controller.dart';
import 'package:purse_for_evmorbtc/page/switchWalletsPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../http/api.dart';
import 'WalletStorage.dart';

class MainAppBar extends StatefulWidget {
  @override
  _MainAppBarState createState() => _MainAppBarState();
}

class _MainAppBarState extends State<MainAppBar> {
  final NetworkController networkController = Get.find<NetworkController>();

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

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final appBarHeight = isIOS ? 100.0 : 88.0;

    return Container(
      height: appBarHeight,
      padding: EdgeInsets.fromLTRB(Adapt.px(26), Adapt.px(55), 0, 0),
      color: Color(0xFF110A3A),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              final result = await Get.to(
                () => SwitchWalletsPage(
                  currentAccount: networkController.account,
                ),
              );
              if (result != null) {
                print("result:" + result);
                networkController.updateAccount(result);
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                await prefs.setString('lastAccount', result);

                // 获取钱包数据
                final wallet = await WalletStorage.getWallet(result);
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
            },
            child: Obx(() => Container(
                margin: EdgeInsets.only(top: Adapt.px(20)),
                padding: EdgeInsets.all(Adapt.px(16)),
                decoration: BoxDecoration(
                  // color: Color.fromRGBO(255, 255, 255, 0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.people,
                      size: 16,
                      color: Colors.white,
                    ),
                    SizedBox(width: Adapt.px(8)),
                    Text(
                      networkController.account,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_drop_down,
                      size: 16,
                      color: Colors.white,
                    ),
                  ],
                ))),
          ),
          SizedBox(width: Adapt.px(100)),
          GestureDetector(
            onTap: () async {
              final result = await Get.to(() => NetworkSelectPage());
              if (result != null) {
                networkController.updateNetwork(result);
              }
            },
            child: Obx(() => Row(
                  children: [
                    Text(
                      networkController.network,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_drop_down,
                      size: 16,
                      color: Colors.white,
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
