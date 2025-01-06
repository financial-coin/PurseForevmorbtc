import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purse_for_evmorbtc/tools/Adapt.dart';
import 'package:purse_for_evmorbtc/tools/WalletStorage.dart';
import 'package:purse_for_evmorbtc/controllers/network_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletManagementPage extends StatefulWidget {
  @override
  _WalletManagementPageState createState() => _WalletManagementPageState();
}

class _WalletManagementPageState extends State<WalletManagementPage> {
  final NetworkController networkController = Get.find<NetworkController>();
  late String currentWalletName = '';
  late String currentNetwork = "";
  late String walletAddress = '';
  late String walletAddressBtc = '';
  late String mnemonic = '';
  late bool mnemonicCopy = false;
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      currentWalletName = networkController.account;
      currentNetwork = networkController.network;
    });

    _loadWalletAddress();
    // 延迟显示密码弹窗，避免和页面动画冲突
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPasswordDialog();
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  // 显示密码输入弹窗
  void _showPasswordDialog() {
    Get.bottomSheet(
      Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.3, // 降低高度到30%
        decoration: BoxDecoration(
          color: Color(0xFF110A3A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部标题栏
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '输入密码',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.back();
                      Get.back();
                    },
                    child: Container(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 输入框部分
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF1C1259),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: '请输入',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),

            // 确认按钮
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 20,
                top: 20, // 减少顶部间距
              ),
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF6A4CFF),
                      Color(0xFF6A4CFF).withOpacity(0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextButton(
                  onPressed: () async {
                    final wallet =
                        await WalletStorage.getWallet(currentWalletName);
                    print(wallet);
                    if (wallet != null) {
                      final passWord = wallet['passWord'];
                      print(passWord);
                      if (_passwordController.text == passWord) {
                        Get.back();
                      } else {
                        Get.snackbar(
                          '错误',
                          '密码错误',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    }
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Center(
                    child: Text(
                      '确认',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
    );
  }

  Future<void> _loadWalletAddress() async {
    final wallet = await WalletStorage.getWallet(currentWalletName);
    if (wallet != null) {
      setState(() {
        walletAddress = wallet['evmAddress'] ?? '';
        walletAddressBtc = wallet['btcAddress'] ?? '';
        mnemonic = wallet['mnemonic'] ?? '';
      });
    }
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
        title: Text(
          '钱包管理',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
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
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF1C1259),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentWalletName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    if (currentNetwork != 'Bitcoin')
                      Row(
                        children: [
                          Text(
                            'EVM: ',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _formatAddress(walletAddress),
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.copy,
                                color: Colors.white70, size: 16),
                            constraints: BoxConstraints(),
                            padding: EdgeInsets.only(left: 4),
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: walletAddress));
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
                    if (currentNetwork == 'Bitcoin')
                      Row(
                        children: [
                          Text(
                            'BTC: ',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _formatAddress(walletAddressBtc),
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.copy,
                                color: Colors.white70, size: 16),
                            constraints: BoxConstraints(),
                            padding: EdgeInsets.only(left: 4),
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: walletAddressBtc));
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
                  ],
                ),
              ),
              SizedBox(height: 32),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF1C1259),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      '钱包名',
                      currentWalletName,
                      onTap: () {
                        // 修改钱包名逻辑
                      },
                    ),
                    Divider(color: Colors.white.withOpacity(0.1)),
                    _buildMenuItem(
                      '导出私钥',
                      '',
                      onTap: () {
                        // 导出私钥逻辑
                        Get.toNamed('/WalletManagementPriPage', arguments: {
                          "account": currentWalletName,
                          "currentNetwork": currentNetwork
                        });
                      },
                    ),
                    Divider(color: Colors.white.withOpacity(0.1)),
                    _buildMenuItem(
                      '备份助记词',
                      mnemonicCopy ? '已备份' : '未备份',
                      showWarning: true,
                      onTap: () {
                        // 备份助记词逻辑
                        setState(() {
                          mnemonicCopy = true;
                        });
                        Clipboard.setData(ClipboardData(text: mnemonic));
                        Get.snackbar(
                          '复制成功',
                          '助记词已复制到剪贴板',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        Get.toNamed('/WalletManagementMicPage', arguments: {
                          "account": currentWalletName,
                          "currentNetwork": currentNetwork
                        });
                      },
                    ),
                  ],
                ),
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    _showDeleteConfirmDialog();
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: BorderSide(color: Colors.red),
                  ),
                  child: Text(
                    '删除',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, String subtitle,
      {bool showWarning = false, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showWarning)
            Container(
              margin: EdgeInsets.only(right: 8),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: mnemonicCopy
                    ? Colors.green.withOpacity(0.5)
                    : Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                mnemonicCopy ? '✔️' : '!',
                style: TextStyle(
                  color: mnemonicCopy ? Colors.green : Colors.orange,
                  fontSize: 12,
                ),
              ),
            ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          if (title != "钱包名") Icon(Icons.chevron_right, color: Colors.white70),
        ],
      ),
      onTap: onTap,
    );
  }

  String _formatAddress(String address) {
    if (address.length < 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  void _showDeleteConfirmDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Color(0xFF1C1259),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '确认删除',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '删除钱包后无法恢复，请确保已备份助记词或私钥',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              '取消',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final allKeys = await WalletStorage.getAllKeys();
              print('allKeys: $allKeys');
              if (allKeys.length >= 2) {
                // 删除钱包逻辑
                await WalletStorage.deleteWallet(currentWalletName);
                // 获取第一个钱包
                final allKeys1 = await WalletStorage.getAllKeys();
                print('allKeys: $allKeys1');

                final firstAccount = allKeys1.isNotEmpty ? allKeys1[0] : '';
                networkController.setAccount(firstAccount);
                Get.back();
                Get.back(result: {'switchAccount': firstAccount});
              } else {
                Get.snackbar(
                  '错误',
                  '至少保留一个钱包',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: Text(
              '确认删除',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
