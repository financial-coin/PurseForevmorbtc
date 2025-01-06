import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purse_for_evmorbtc/tools/Adapt.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/network_controller.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPagePageState();
}

class _DiscoverPagePageState extends State<DiscoverPage> {
  final NetworkController networkController = Get.find<NetworkController>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Widget _buildSection(String title, List<MenuItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 21,
            ),
          ),
        ),
        ...items.map((item) => _buildMenuItem(item)).toList(),
        // SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMenuItem(MenuItem item) {
    return Container(
        margin: EdgeInsets.only(
            bottom: Adapt.px(20), left: Adapt.px(16), right: Adapt.px(16)),
        // padding: EdgeInsets.all(Adapt.px(16)),
        decoration: BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: Icon(
            item.icon,
            color: Color(0xFF6A4CFF),
            size: 25,
          ),
          title: Text(
            item.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: Colors.white.withOpacity(0.5),
            size: 20,
          ),
          onTap: item.onTap,
        ));
  }

  Widget _buildSection1(String title, List<MenuItem1> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 21,
            ),
          ),
        ),
        ...items.map((item) => _buildMenuItem1(item)).toList(),
        // SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMenuItem1(MenuItem1 item) {
    return Container(
        margin: EdgeInsets.only(
            bottom: Adapt.px(20), left: Adapt.px(16), right: Adapt.px(16)),
        // padding: EdgeInsets.all(Adapt.px(16)),
        decoration: BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: Icon(
            item.icon,
            color: Color(0xFF6A4CFF),
            size: 25,
          ),
          title: Text(
            item.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
            ),
          ),
          trailing: Text(
            item.subtitle,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 19,
            ),
          ),
          onTap: item.onTap,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // String BalanceValue = getBalance().toString();
      if (networkController.isNetworkChanged.value) {
        // refreshData(); // 调用刷新方法
        networkController.isNetworkChanged.value = false; // 重置状态
      }
      final currentNetwork = networkController.network;
      final account = networkController.account;
      // 根据当前网络筛选显示相应的数据
      // final filteredTransactions = transactions.where((tx) {
      //   // if (currentNetwork == '全部网络') return true;
      //   return tx['name'].toString().contains(currentNetwork);
      // }).toList();

      // return Obx(() {
      //   // String BalanceValue = getBalance().toString();
      //   if (networkController.isNetworkChanged.value) {
      //     // refreshData(); // 调用刷新方法
      //     networkController.isNetworkChanged.value = false; // 重置状态
      //   }
      // }).toList();
      // final currentNetwork = networkController.network;
      // final account = networkController.account;

      return Scaffold(
        backgroundColor: Color(0xFF110A3A),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection('基本功能', [
                // MenuItem(
                //   icon: Icons.swap_horiz,
                //   title: '兑换',
                //   onTap: () {
                //     Get.toNamed('/ExchangePage');
                //   },
                // ),
                if (currentNetwork == 'Bitcoin')
                  MenuItem(
                    icon: Icons.account_balance_wallet,
                    title: 'stake',
                    onTap: () {
                      Get.toNamed('/StakePage');
                    },
                  ),
                if (currentNetwork == 'Bitcoin')
                  MenuItem(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'unstake',
                    onTap: () {
                      Get.toNamed('/UnstakePage');
                    },
                  ),
                MenuItem(
                  icon: Icons.arrow_upward,
                  title: '发送',
                  onTap: () {
                    Get.toNamed('/SendPage', arguments: {
                      "currentNetwork": currentNetwork,
                      "account": account
                    });
                  },
                ),
                MenuItem(
                  icon: Icons.arrow_downward,
                  title: '接收',
                  onTap: () {
                    Get.toNamed('/ReceivePage', arguments: {
                      "currentNetwork": currentNetwork,
                      "account": account
                    });
                  },
                ),
                MenuItem(
                  icon: Icons.swap_horiz,
                  title: 'gas兑换',
                  onTap: () {
                    Get.toNamed('/GasExchangePage', arguments: {
                      "currentNetwork": currentNetwork,
                      "account": account
                    });
                  },
                ),
                MenuItem(
                  icon: Icons.shopping_cart,
                  title: '钱包管理',
                  onTap: () async {
                    final result = await Get.toNamed('/WalletManagementPage',
                        arguments: {
                          "currentNetwork": currentNetwork,
                          "account": account
                        });

                    if (result != null && result is Map<String, dynamic>) {
                      final switchAccount = result['switchAccount'] as String;
                      if (switchAccount.isNotEmpty) {
                        // 切换到第一个账号

                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setString('lastAccount', switchAccount);
                        // 可以添加切换成功的提示
                        Get.snackbar(
                          '提示',
                          '已切换到钱包: $switchAccount',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    }
                  },
                ),
                // MenuItem(
                //   icon: Icons.money,
                //   title: '提币',
                //   onTap: () {},
                // ),
              ]),
              _buildSection1('设置', [
                MenuItem1(
                  icon: Icons.palette,
                  title: '主题',
                  subtitle: '暗色',
                  onTap: () {},
                ),
                MenuItem1(
                  icon: Icons.language,
                  title: '语言',
                  subtitle: '中文',
                  onTap: () {},
                ),
                MenuItem1(
                  icon: Icons.attach_money,
                  title: '默认币值',
                  subtitle: 'USD',
                  onTap: () {},
                ),
                MenuItem1(
                  icon: Icons.info_outline,
                  title: '最新版本',
                  subtitle: '1.0.0',
                  onTap: () {},
                ),
              ]),
              // _buildSection('学院', [
              //   MenuItem(
              //     icon: Icons.school,
              //     title: 'DEFI 知识库',
              //     onTap: () {},
              //   ),
              //   MenuItem(
              //     icon: Icons.route,
              //     title: '理财有道',
              //     onTap: () {},
              //   ),
              //   MenuItem(
              //     icon: Icons.article,
              //     title: '行业资讯',
              //     onTap: () {},
              //   ),
              //   MenuItem(
              //     icon: Icons.auto_awesome,
              //     title: '自动化策略',
              //     onTap: () {},
              //   ),
              //   MenuItem(
              //     icon: Icons.warning_amber,
              //     title: '风险',
              //     onTap: () {},
              //   ),
              // ]),
              // _buildSection('社区治理', [
              //   MenuItem(
              //     icon: Icons.monetization_on,
              //     title: '如何发行代币',
              //     onTap: () {},
              //   ),
              //   MenuItem(
              //     icon: Icons.group,
              //     title: '如何参与社区治理',
              //     onTap: () {},
              //   ),
              //   MenuItem(
              //     icon: Icons.how_to_vote,
              //     title: '如何投票',
              //     onTap: () {},
              //   ),
              // ]),
              // _buildSection('生态建设', [
              //   MenuItem(
              //     icon: Icons.add_circle_outline,
              //     title: '如何新增稳定币',
              //     onTap: () {},
              //   ),
              //   MenuItem(
              //     icon: Icons.handshake,
              //     title: '接入更多DEFI协议',
              //     onTap: () {},
              //   ),
              //   MenuItem(
              //     icon: Icons.account_balance,
              //     title: '如何增加出入金通道',
              //     onTap: () {},
              //   ),
              // ]),
            ],
          ),
        ),
      );
    });
  }
}

class MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}

class MenuItem1 {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  MenuItem1({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
