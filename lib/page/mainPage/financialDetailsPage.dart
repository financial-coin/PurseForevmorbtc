import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purse_for_evmorbtc/tools/Adapt.dart';
// import 'package:url_launcher/url_launcher.dart';

import '../../http/api.dart';
import '../../http/dio_utils.dart';

class FinancialDetailsPage extends StatefulWidget {
  const FinancialDetailsPage({Key? key}) : super(key: key);

  @override
  _FinancialDetailsPageState createState() => _FinancialDetailsPageState();
}

class _FinancialDetailsPageState extends State<FinancialDetailsPage> {
  late final Map<String, dynamic> itemData;

  @override
  void initState() {
    super.initState();
    itemData = Get.arguments["item"];
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
          itemData['tokenSymbol'] ?? '主题理财',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
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
              // 顶部卡片
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFF1C1259),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          itemData['tokenSymbol'] ?? 'BTC 核心理财',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 16),
                        ...(itemData['tokenTag'].split('|') ?? []).map(
                          (tag) => Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: _buildTag(tag, Color(0xFFFFA500)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          itemData['showApr']?.toString() ?? '',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Text(
                        //   itemData['buyers']?.toString() ?? '204.32k人购买',
                        //   style: TextStyle(
                        //     color: Colors.white,
                        //     fontSize: 14,
                        //   ),
                        // ),
                      ],
                    ),
                    Text(
                      '近一年净值收益率',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              // 产品介绍
              _buildSection('产品介绍', [itemData['tokenDescription']]),
              // _buildSection('奖励规则', [
              //   '当用户每日将额取USUAL代币作为���励），领取数量根据产品协议自动计算。',
              //   'USD0++ and liquidity rewards have a 7-day verification period before distributions begin. After that, rewards are distributed daily and can be claimed from your account.',
              //   'Usual rewards are distributed on a 24-hour cycle. At the end of each cycle, data is sent on-chain, a process that may take up to 1 hour, while the next cycle begins simultaneously.',
              // ]),
              // _buildSection('申购｜赎回规则', [
              //   '购买规则：',
              //   '购买限额：',
              //   '一些年后可能会设定每日 每月每年的购买限额特别是在在进行法币兑换的时候，这与反洗钱法规和监管要求实际上是相关的。费率和交易成本不同平台和产品可能会收取不同的手续费用，用户需要明晰了解购买时的费用结构，包括交易费、提现费',
              //   '赎回规则：',
              //   '每天最多可以即时赎回20000USDT，如需要赎回更多自己可能需要1天。',
              // ]),
              _buildSection('合规与风险', [
                '风险提示：',
                '虚拟货币市场具有高度的波动性，用户在进行投资和理财前需要了解清楚在风险部分平台全提供风险提示，提醒用户市场可能出现的波动',
                '法律与合规：',
                '虚拟货币涉及的法律和税务问题因国家和地区而异，部分国家可能禁止或限制虚拟货币的交易和投资，而其他国家可能采取较为开放的监管政策。用户需要确保其投资活动符合当地的法律法规',
              ]),
              _buildSection('储备证明', [
                '发行商已经为用户提供资产保险服务，详细>>',
              ]),
              _buildSection('合约审计报告', [
                '合约已经通过审计，详细>>',
              ]),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        color: Color(0xFF110A3A),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Get.toNamed('/SubscribePage', arguments: {
                    "evmAddress": Get.arguments['evmAddress'],
                    "btcAddress": Get.arguments['btcAddress'],
                    "item": itemData
                  });
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF1C1259),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text('申购'),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Get.toNamed('/RedemptionPage', arguments: {
                    "evmAddress": Get.arguments['evmAddress'],
                    "btcAddress": Get.arguments['btcAddress'],
                    "item": itemData
                  });
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF6A4CFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text('赎回'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> contents) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        ...contents
            .map((content) => Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      // 普通文本部分
                      Expanded(
                        child: Text(
                          content.replaceAll('，详细>>', ''), // 移除"详细>>"部分
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                      // 如果包含"详细>>"则显示可点击部分
                      if (content.contains('详细>>'))
                        GestureDetector(
                          onTap: () {
                            final url = itemData['tokenUrl'];
                            if (url != null) {
                              Get.toNamed('/WebViewPage',
                                  arguments: {'url': url});
                            }
                          },
                          child: Text(
                            '详细>>',
                            style: TextStyle(
                              color: Color(0xFF6A4CFF),
                              fontSize: 14,
                              height: 1.5,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                    ],
                  ),
                ))
            .toList(),
        SizedBox(height: 24),
      ],
    );
  }
}
