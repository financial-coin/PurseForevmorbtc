import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:purse_for_evmorbtc/tools/Adapt.dart';
import 'package:get/get.dart';
import 'package:purse_for_evmorbtc/controllers/network_controller.dart';
import 'package:purse_for_evmorbtc/page/mainPage/receivePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../http/api.dart';
import '../../http/dio_utils.dart';
import '../../tools/WalletBalance.dart';
import '../../tools/WalletStorage.dart';
import '../../tools/WalletTockenBlance.dart';
import '../../tools/constants.dart'; // 导入常量文件
import 'package:purse_for_evmorbtc/tools/WalletRestore.dart';
import 'dart:convert' as convert;
import 'dart:convert'; // 添加这个导入

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePagePageState();
}

class _HomePagePageState extends State<HomePage> {
  final NetworkController networkController = Get.find<NetworkController>();
  String? evmAddress1 = "";
  String? btcAddress1 = "";
  var balance = 0.0;
  String BalanceD = "0.00";

  // 更新测试数据结构
  List transactions = [
    // {
    //   'tokenSymbol': 'BTC永续合约',
    //   'showApr': '105%',
    //   'buyers': '1.2万人',
    //   'tokenTag': '稳定|高收益|高完金'
    // },
  ];

  // 添加新变量控制提示条显示状态
  bool showGasAlert = true;
  double gasBalance = 0.0;
  final double minGasRequired = 0.01; // 最小需要的 gas 数量（单位：MATIC）

  Widget _buildTransactionList() {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "lib/images/icon_none_data.png",
              width: Adapt.px(360),
              height: Adapt.px(360),
              fit: BoxFit.fill,
            ),
            SizedBox(height: Adapt.px(10)),
            const Text(
              '暂无数据',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final item = transactions[index];
          return GestureDetector(
            onTap: () {
              Get.toNamed(
                '/FinancialDetailsPage',
                arguments: {
                  "evmAddress": evmAddress1,
                  "btcAddress": btcAddress1,
                  "item": item
                },
              );
            },
            child: Container(
              margin: EdgeInsets.only(bottom: Adapt.px(20)),
              padding: EdgeInsets.all(Adapt.px(16)),
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 第一行：名称和标签
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 名称
                      Text(
                        item['tokenSymbol']?.toString() ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: Adapt.px(12)),
                      Wrap(
                        spacing: 8,
                        children: (item['tokenTag'].split('|') ?? [])
                            .map<Widget>((tag) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Adapt.px(8),
                              vertical: Adapt.px(2),
                            ),
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(255, 144, 0, 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                color: Color(0xFFFF6B00),
                                fontSize: 12,
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                  SizedBox(height: Adapt.px(12)),
                  // 第二行：收益比例和购买人数
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['showApr']?.toString() ?? '',
                        style: TextStyle(
                          color: (item['showApr'] is String &&
                                  item['showApr'].startsWith('-'))
                              ? Color(0xFFFF5D5D)
                              : Colors.green,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Text(
                      //   item['buyers']?.toString() ?? '',
                      //   style: TextStyle(
                      //     color: Colors.white,
                      //     fontSize: 14,
                      //   ),
                      // ),
                    ],
                  ),
                  SizedBox(height: Adapt.px(8)),
                  // 第三行：近一年收益率
                  Text(
                    '近一年收益率',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPublicKey();
    Api.initBaseUrl();
    // getBalance();
    _loadData();
  }

//   请求URL: https://devnet-financial.qday.ninja/financial/user/balance/1/0x87cfbac24a4762cb86f440b82b958082d4d22077
// flutter: 请求参数: null
// flutter: ----> 查询

  Future<void> _loadData() async {
    if (HttpUtils.instance.dio != null) {
      if (Api.baseUrl != HttpUtils.getBaseUrl()) {
        HttpUtils.setBaseUrl();
      }
    }
    try {
      final res = await HttpUtils.instance.get(
        "${Api.defiListUrl}1",
        tips: false,
        context: context,
      );

      if (res.code == 0) {
        setState(() {
          transactions = res.data;
        });
      }
    } catch (e) {
      print("加载数据错误: $e");
    }
  }

  Future<void> getBalanceD() async {
    try {
      final res = await HttpUtils.instance.get(
        "${Api.balanceUrl}1/$evmAddress1",
        tips: false,
        context: context,
      );

      if (res.code == 0) {
        setState(() {
          BalanceD = res.data.toString();
        });
      }
    } catch (e) {
      print("加载数据错误: $e");
    }
  }

  Future<void> getBalanceB() async {
    try {
      final res = await HttpUtils.instance.get(
        "${Api.btcBalanceUrl}1/$btcAddress1",
        tips: false,
        context: context,
      );

      if (res.code == 0) {
        setState(() {
          BalanceD = res.data.toString();
        });
      }
    } catch (e) {
      print("加载数据错误: $e");
    }
  }

  getPublicKey() async {
    final currentAccount = networkController.account;

    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    // final String? evmAddress = prefs.getString('evmAddress');
    // final String? btcAddress = prefs.getString('btcAddress');

    final wallet = await WalletStorage.getWallet(currentAccount);
    if (wallet != null) {
      final evmAddress = wallet['evmAddress'];
      final btcAddress = wallet['btcAddress'];
      // ... 使用其他数据
      setState(() {
        evmAddress1 = evmAddress;
        btcAddress1 = btcAddress;
      });
      _checkGasBalance(); // 添加检查 gas 余额
      // getBalance();
    }

    // await prefs.setString('evmAddress', evmAddress!);
    // await prefs.setString('evmPrikey', evmPrikey!);
    // await prefs.setString('btcAddress', btcAddress!);
    // await prefs.setString('btcPrikey', btcPrikey!);
    // await prefs.setString('btcWIF', btcWIF!);
  }

  String formatString(String input) {
    if (input.length <= 10) {
      return input; // 如果字符串长度小于等于10，直接返回
    }
    String start = input.substring(0, 6); // 获取前6位
    String end = input.substring(input.length - 4); // 获取后4位
    return '$start...$end'; // 拼接结果
  }

  getBalance() async {
    print('----> 查询');
    getPublicKey();
    // double BalanceValue = 0;
    final currentNetwork = networkController.network;
    final walletBalance = WalletBalance();
    if (currentNetwork == "Bitcoin") {
      getBalanceB();
    } else {
      getBalanceD();
    }
    // return BalanceValue.toString();
  }

  void refreshData() {
    getBalance(); // 重新获取余额
  }

  // 添加检查 gas 余额的方法
  Future<void> _checkGasBalance() async {
    try {
      final balance = await WalletTockenBlance.fetchBalance(evmAddress1 ?? '');
      setState(() {
        gasBalance = double.parse(balance) / BigInt.from(10).pow(18).toDouble();
        showGasAlert = gasBalance < minGasRequired;
      });
    } catch (e) {
      print('检查 gas 余额失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // String BalanceValue = getBalance().toString();
      if (networkController.isNetworkChanged.value) {
        refreshData(); // 调用刷新方法
        networkController.isNetworkChanged.value = false; // 重置状态
      }
      final currentNetwork = networkController.network;
      final currentAccount = networkController.account;
      // 根据当前网络筛选显示相应的数据
      final filteredTransactions = transactions.where((tx) {
        // if (currentNetwork == '全部网络') return true;
        return tx['name'].toString().contains(currentNetwork);
      }).toList();

      return Scaffold(
        backgroundColor: Color(0xFF110A3A), // 深紫色背景
        body: Column(
          children: [
            // 添加 Gas 提示条
            if (showGasAlert)
              GestureDetector(
                onTap: () {
                  // 点击跳转到充值页面
                  Get.toNamed('/GasExchangePage', arguments: {
                    "currentNetwork": networkController.network,
                    "account": networkController.account
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: Adapt.px(16),
                    vertical: Adapt.px(8),
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFFF6B00).withOpacity(0.1),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFFF6B00),
                        size: 20,
                      ),
                      SizedBox(width: Adapt.px(8)),
                      Expanded(
                        child: Text(
                          'Gas 费用不足，当前余额: ${gasBalance.toStringAsFixed(4)} MATIC，点击充值',
                          style: const TextStyle(
                            color: Color(0xFFFF6B00),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        icon: Icon(
                          Icons.close,
                          color: Color(0xFFFF6B00),
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            showGasAlert = false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

            // 原有的页面内容放在 Expanded 中
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  Adapt.px(26),
                  0,
                  Adapt.px(26),
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 钱包地址和余额
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          currentNetwork == "Bitcoin"
                              ? "BTC: " + formatString(btcAddress1!)
                              : "EVM: " + formatString(evmAddress1!),
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.copy,
                            color: Colors.white,
                            size: 16,
                          ),
                          onPressed: () {
                            // 视图切换逻辑
                            Clipboard.setData(ClipboardData(
                                text: currentNetwork == "Bitcoin"
                                    ? btcAddress1
                                    : evmAddress1));
                            Get.snackbar(
                              '复制成功',
                              '地址已复制到剪贴板',
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        ),
                        // Container(
                        //     height: Adapt.px(40),
                        //     width: Adapt.px(1),
                        //     color: Colors.white),
                        // SizedBox(width: Adapt.px(30)),
                        // const Icon(
                        //   Icons.local_gas_station_outlined,
                        //   color: Colors.white,
                        //   size: 19,
                        // ),
                        // const Text(
                        //   '12.88',
                        //   style: TextStyle(color: Colors.white70, fontSize: 16),
                        // ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Obx(() => Text(
                                      networkController.isBalanceVisible
                                          ? "\$ $BalanceD"
                                          : '\$****',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold),
                                    )),
                                IconButton(
                                  icon: Obx(() => Icon(
                                      networkController.isBalanceVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.white)),
                                  onPressed: () {
                                    networkController.toggleBalanceVisibility();
                                  },
                                ),
                              ]),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  currentNetwork == "Bitcoin"
                                      ? Get.toNamed('/MyAssetsBTCPage',
                                          arguments: {
                                              "account": currentAccount
                                            })
                                      : Get.toNamed('/MyAssetsPage',
                                          arguments: {
                                              "account": currentAccount
                                            });
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      '展开',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        ]),

                    SizedBox(height: Adapt.px(30)),

                    // Spacer(),
                    // 按钮行
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildActionButton(Icons.arrow_downward, '接收'),
                          _buildActionButton(Icons.arrow_upward, '发送'),
                          // _buildActionButton(Icons.swap_horiz, '兑换'),
                          // _buildActionButton(Icons.add, '购买'),
                        ],
                      ),
                    ),

                    SizedBox(height: Adapt.px(30)),

                    // 交易列表或空状态
                    _buildTransactionList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildActionButton(IconData icon, String label) {
    final currentNetwork = networkController.network;
    final currentAccount = networkController.account;

    return Expanded(
      // 添加 Expanded 让按钮平分宽度
      child: Container(
        height: 50, // 设置固定高度
        margin: EdgeInsets.symmetric(horizontal: 8), // 按钮之间的间距
        child: ElevatedButton(
          onPressed: () {
            switch (label) {
              case '接收':
                Get.toNamed(
                    currentNetwork == "Bitcoin"
                        ? '/ReceivePage'
                        : '/ReceiveCoinPage',
                    arguments: {
                      "currentNetwork": currentNetwork,
                      "account": currentAccount
                    });
                break;
              case '发送':
                Get.toNamed('/SendPage', arguments: {
                  "currentNetwork": currentNetwork,
                  "account": currentAccount
                });
                break;
            }
          },
          style: ElevatedButton.styleFrom(
            primary: Color(0xFF6A4CFF), // 紫色背景
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // 圆角
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
