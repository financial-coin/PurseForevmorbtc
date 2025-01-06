import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purse_for_evmorbtc/tools/Adapt.dart';
import 'package:purse_for_evmorbtc/controllers/network_controller.dart';

import '../tools/WalletStorage.dart';

class SwitchCoinPage extends StatefulWidget {
  final String currentAccount;

  const SwitchCoinPage({
    Key? key,
    required this.currentAccount,
  }) : super(key: key);

  @override
  _SwitchCoinPageState createState() => _SwitchCoinPageState();
}

class _SwitchCoinPageState extends State<SwitchCoinPage> {
  // final NetworkController networkController = Get.find<NetworkController>();
  late String selectedWallet;
  late List<Map<String, dynamic>> wallets = [];

  @override
  void initState() {
    super.initState();
    selectedWallet = widget.currentAccount;
    _loadWallets();
  }

  Future<void> _loadWallets() async {
    setState(() {
      wallets = [
        {
          "name": "ETH",
          "icon": "lib/images//ETH.png",
          "address": "",
          'isSelected': "ETH" == selectedWallet,
        },
        {
          "name": "BTU",
          "icon": "lib/images/BTU.png",
          "address": "0x123456789012359678qwsdfdfg234324324234234",
          'isSelected': "BTU" == selectedWallet,
        },
        {
          "name": "USDC",
          "icon": "lib/images/USDC.png",
          "address": "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",
          'isSelected': "USDC" == selectedWallet,
        },
        {
          "name": "USDT",
          "icon": "lib/images/USDT.png",
          "address": "0xdac17f958d2ee523a2206206994597c13d831ec7",
          'isSelected': "USDT" == selectedWallet,
        },
      ];
    });

    print(wallets);
  }

  // 修改选择钱包的方法
  void _selectWallet(Map<String, dynamic> wallet) {
    if (wallet['name'] == selectedWallet) {
      // 如果点击的是当前选中的钱包，直接返回
      Get.back();
      return;
    }

    setState(() {
      // 取消所有钱包的选中状态
      for (var w in wallets) {
        w['isSelected'] = false;
      }
      // 设置当前钱包为选中状态
      wallet['isSelected'] = true;
      selectedWallet = wallet['name'];
    });
    // 更新控制器中的账号
    // networkController.updateAccount(selectedWallet);
    Get.back(result: selectedWallet);
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
        title: const Text(
          '选择币种',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: wallets.length,
              itemBuilder: (context, index) {
                final wallet = wallets[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Color(0xFF1C1259),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Row(
                      children: [
                        Image.asset(
                          wallet['icon'],
                          width: 32,
                          height: 32,
                        ),
                        SizedBox(width: Adapt.px(16)),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                wallet['name'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                formatString(wallet['address']),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ]),
                      ],
                    ),
                    // subtitle: Text(
                    //   wallet['balance'],
                    //   style: TextStyle(
                    //     color: Colors.white70,
                    //     fontSize: 14,
                    //   ),
                    // ),
                    trailing: wallet['isSelected']
                        ? Icon(Icons.check, color: Color(0xFF6A4CFF))
                        : null,
                    onTap: () => _selectWallet(wallet),
                  ),
                );
              },
            ),
          ),
          // Padding(
          //   padding: EdgeInsets.all(16),
          //   child: SizedBox(
          //     width: double.infinity,
          //     height: 50,
          //     child: ElevatedButton(
          //       onPressed: () {
          //         Get.toNamed('/CreateWalletForMnemonic');
          //       },
          //       style: ElevatedButton.styleFrom(
          //         primary: Color(0xFF6A4CFF),
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(25),
          //         ),
          //       ),
          //       child: Text(
          //         '+ 添加钱包',
          //         style: TextStyle(
          //           color: Colors.white,
          //           fontSize: 16,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  String formatString(String input) {
    if (input.length <= 10) {
      return input; // 如果字符串长度小于等于10，直接返回
    }
    String start = input.substring(0, 6); // 获取前6位
    String end = input.substring(input.length - 6); // 获取后4位
    return '$start...$end'; // 拼接结果
  }
}
