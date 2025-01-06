import 'package:flutter/material.dart';
import 'package:purse_for_evmorbtc/tools/Adapt.dart';
import 'package:get/get.dart';
import 'package:purse_for_evmorbtc/controllers/network_controller.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../http/api.dart';
import '../../http/dio_utils.dart';
import '../../tools/WalletStorage.dart';

class HistoricalDataPage extends StatefulWidget {
  const HistoricalDataPage({super.key});

  @override
  State<HistoricalDataPage> createState() => _HistoricalDataPageState();
}

class _HistoricalDataPageState extends State<HistoricalDataPage> {
  final NetworkController networkController = Get.find<NetworkController>();

  // 添加刷新控制器
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  int _currentPage = 1;
  bool _hasMore = true;
  int _total = 0;

  // 交易数据列表
  List transactions = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  // 初始加载数据
  Future<void> _loadInitialData() async {
    _currentPage = 1;
    transactions.clear();
    await _loadData(isRefresh: true);
  }

  // 加载数据的核心方法
  Future<void> _loadData({bool isRefresh = false}) async {
    try {
      // 如果是刷新，重置页码和数据
      if (isRefresh) {
        _currentPage = 1;
        transactions.clear();
        _hasMore = true; // 重置加载更多状态
      }
      final currentAccount = networkController.account;
      String evmAddress = "";
      final wallet = await WalletStorage.getWallet(currentAccount);
      if (wallet != null) {
        evmAddress = wallet['evmAddress'];
      }

      final params = {
        'chainId': 1,
        'address': "0x1234fromaddress", //evmAddress,
        'page': _currentPage,
        'pageSize': 10,
      };

      print("\n=== 请求参数 ===");
      print("当前页码: $_currentPage");
      print("URL: ${Api.baseUrl}${Api.txListUrl}");
      print("参数: $params\n");

      final res = await HttpUtils.instance.get(
        Api.txListUrl,
        params: params,
        tips: false,
        context: context,
      );

      if (res.code == 0 && res.data != null) {
        setState(() {
          if (res.data is Map) {
            final List? newList = res.data['list'];
            if (newList != null) {
              transactions.addAll(newList);
            }
            // 更新总数
            _total = res.data['total'] ?? 0;

            // 计算是否还有更多数据
            int currentPageLastIndex = _currentPage * 10; // 当前页的最后一条数据的理论索引
            _hasMore = currentPageLastIndex < _total; // 如果还有数据未加载则为true

            print("\n=== 分页信息 ===");
            print("当前页码: $_currentPage");
            print("当前数据量: ${transactions.length}");
            print("总数据量: $_total");
            print("当前页最后索引: $currentPageLastIndex");
            print("是否有更多: $_hasMore\n");
          }
        });

        // 更新刷新控件状态
        if (isRefresh) {
          _refreshController.refreshCompleted();
          // 只有在真的没有数据时才显示无数据状态
          if (_total == 0) {
            _refreshController.loadNoData();
          } else {
            // 重置加载更多状态
            _refreshController.loadComplete();
          }
        } else {
          if (_hasMore) {
            _refreshController.loadComplete();
          } else {
            _refreshController.loadNoData();
          }
        }
      } else {
        print("请求失败: ${res.message}");
        if (isRefresh) {
          _refreshController.refreshFailed();
        } else {
          _refreshController.loadFailed();
        }
      }
    } catch (e) {
      print("加载数据错误: $e");
      if (isRefresh) {
        _refreshController.refreshFailed();
      } else {
        _refreshController.loadFailed();
      }
    }
  }

  // 下拉刷新
  void _onRefresh() async {
    _currentPage = 1;
    await _loadData(isRefresh: true);
  }

  // 上拉加载更多
  void _onLoading() async {
    if (!_hasMore) {
      _refreshController.loadNoData();
      return;
    }
    _currentPage++;
    await _loadData(isRefresh: false);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentNetwork = networkController.network;

      return Scaffold(
        backgroundColor: Color(0xFF110A3A),
        body: Padding(
          padding: EdgeInsets.fromLTRB(Adapt.px(26), 0, Adapt.px(26), 0),
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
                // 固定在顶部的部分
                SizedBox(height: Adapt.px(10)),
                const Text(
                  '数据交易',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: Adapt.px(20)),
                _buildTableHeader(),

                // 可滚动的列表部分
                Expanded(
                  child: SmartRefresher(
                    enablePullDown: true,
                    enablePullUp: true,
                    header: const WaterDropHeader(
                      waterDropColor: Color(0xFF6A4CFF),
                      complete:
                          Text('刷新完成', style: TextStyle(color: Colors.white)),
                      failed:
                          Text('刷新失败', style: TextStyle(color: Colors.white)),
                    ),
                    footer: CustomFooter(
                      builder: (BuildContext context, LoadStatus? mode) {
                        Widget body;
                        if (mode == LoadStatus.idle) {
                          body = const Text("上拉加载",
                              style: TextStyle(color: Colors.white));
                        } else if (mode == LoadStatus.loading) {
                          body = const CircularProgressIndicator(
                              color: Color(0xFF6A4CFF));
                        } else if (mode == LoadStatus.failed) {
                          body = const Text("加载失败！点击重试！",
                              style: TextStyle(color: Colors.white));
                        } else if (mode == LoadStatus.canLoading) {
                          body = const Text("松手,加载更多!",
                              style: TextStyle(color: Colors.white));
                        } else {
                          body = const Text("没有更多数据了!",
                              style: TextStyle(color: Colors.white));
                        }
                        return Container(
                          height: 55.0,
                          child: Center(child: body),
                        );
                      },
                    ),
                    controller: _refreshController,
                    onRefresh: _onRefresh,
                    onLoading: _onLoading,
                    child: SingleChildScrollView(
                      child: _buildTransactionList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // 表头
  Widget _buildTableHeader() {
    return Container(
      margin: EdgeInsets.only(bottom: Adapt.px(20)),
      padding: EdgeInsets.all(Adapt.px(16)),
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            '交易ID',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '交易内容',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '状态',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '交易额',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 交易列表
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

    return Column(
      children:
          transactions.map((item) => _buildTransactionItem(item)).toList(),
    );
  }

  String formatString(String input) {
    if (input.length <= 7) {
      return input; // 如果字符串长度小于等于10，直接返回
    }
    String start = input.substring(0, 4); // 获取前6位
    String end = input.substring(input.length - 3); // 获取后4位
    return '$start....$end'; // 拼接结果
  }

  // 单个交易项
  Widget _buildTransactionItem(Map<String, dynamic> item) {
    // 获取当前交易在列表中的索引
    int index = transactions.indexOf(item) + 1;
    String txStauts = "";
    Color col = Colors.white;
    if (item['txStauts'] == 0) {
      txStauts = "失败";
      col = Colors.red;
    } else if (item['txStauts'] == 1) {
      txStauts = "成功";
      col = Colors.green;
    } else {
      txStauts = "确认中";
      col = Colors.yellow;
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 添加编号
            // Container(
            //   width: 30,
            //   child: Text(
            //     '$index.',
            //     style: TextStyle(
            //       color: Colors.white,
            //       fontSize: 16,
            //     ),
            //   ),
            // ),
            // txHash
            Text(
              formatString(item['txHash']),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              width: Adapt.px(180),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['signMethod'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    softWrap: true,
                    maxLines: null,
                    overflow: TextOverflow.visible,
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
            Container(
              width: Adapt.px(160),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    txStauts,
                    style: TextStyle(
                      color: col,
                      fontSize: 16,
                    ),
                    softWrap: true,
                    maxLines: null,
                    overflow: TextOverflow.visible,
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
            Text(
              item['amount'],
              style: TextStyle(
                color: double.parse(item['amount']) < 0
                    ? Colors.red
                    : Colors.green,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
        SizedBox(height: Adapt.px(20)),
        Container(
          height: Adapt.px(1),
          width: Adapt.px(660),
          color: Colors.grey,
        ),
      ],
    );
  }
}
