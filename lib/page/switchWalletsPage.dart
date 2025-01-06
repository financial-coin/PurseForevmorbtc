import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purse_for_evmorbtc/tools/Adapt.dart';
import 'package:purse_for_evmorbtc/controllers/network_controller.dart';

import '../tools/WalletStorage.dart';

class SwitchWalletsPage extends StatefulWidget {
  final String currentAccount;

  const SwitchWalletsPage({
    Key? key,
    required this.currentAccount,
  }) : super(key: key);

  @override
  _SwitchWalletsPageState createState() => _SwitchWalletsPageState();
}

class _SwitchWalletsPageState extends State<SwitchWalletsPage> {
  final NetworkController networkController = Get.find<NetworkController>();
  late String selectedWallet;
  late List<Map<String, dynamic>> wallets = [];

  @override
  void initState() {
    super.initState();
    selectedWallet = widget.currentAccount;
    _loadWallets();
  }

  Future<void> _loadWallets() async {
    final allWallets = await WalletStorage.getWallets();
    print(allWallets);
    setState(() {
      wallets = allWallets.entries.map((entry) {
        return {
          'name': entry.key,
          // 'balance': entry.value['balance'],
          'isSelected': entry.key == widget.currentAccount,
          'evmAddress': entry.value['evmAddress'],
          'btcAddress': entry.value['btcAddress'],
        };
      }).toList();
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
    print(selectedWallet);
    networkController.updateAccount(selectedWallet);
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
        title: Text(
          '切换钱包',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        // actions: [
        //   TextButton(
        //     onPressed: () {
        //       // 处理编辑功能
        //     },
        //     child: Text(
        //       '编辑',
        //       style: TextStyle(
        //         color: Color(0xFF6A4CFF),
        //         fontSize: 16,
        //       ),
        //     ),
        //   ),
        // ],
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
                    title: Text(
                      wallet['name'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
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
          Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Get.toNamed('/AddWalletPage');
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF6A4CFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  '+ 添加钱包',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
