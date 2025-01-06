import 'dart:io';

import 'package:flutter/material.dart';
import 'package:badges/badges.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:purse_for_evmorbtc/tools/Adapt.dart';
import 'dart:convert' as convert;

import 'discover.dart';
import 'historicalDataPage.dart';
import 'homePage.dart';

import '../../tools/MainAppBar.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _TabsState();
}

class _TabsState extends State<MainPage> {
  int _currentIndex = 0;
  // bool flag = false;
  int _swipeCount = 0; // 记录滑动次数
  DateTime? _lastSwipeTime; // 记录上次滑动的时间

  final List<Widget> _pages = const [
    HomePage(),
    HistoricalDataPage(),
    DiscoverPage(),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // 返回 false，阻止默认的返回行为
          _handleSwipe1();
          return false;
        },
        child: GestureDetector(
            onHorizontalDragEnd: (details) {
              // 检测到向右滑动
              if (details.velocity.pixelsPerSecond.dx > 0) {
                print("向右滑动");
                _handleSwipe();
              }
            },
            child: Scaffold(
              // drawer: new Drawer(),
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(180.0), // 自定义导航栏高度
                child: MainAppBar(),
              ),
              body: _pages[_currentIndex],

              bottomNavigationBar: BottomNavigationBar(
                  unselectedItemColor: Colors.white,
                  fixedColor: Color.fromRGBO(93, 32, 206, 1), //选中的颜色
                  backgroundColor: const Color.fromRGBO(28, 18, 86, 1),
                  // iconSize:35,           //底部菜单大小
                  currentIndex: _currentIndex, //第几个菜单选中
                  type: BottomNavigationBarType
                      .fixed, //如果底部有4个或者4个以上的菜单的时候就需要配置这个参数
                  onTap: (index) {
                    //点击菜单触发的方法
                    //注意
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  items: [
                    BottomNavigationBarItem(
                        icon: Badge(
                          showBadge: false,
                          badgeContent: Text(""),
                          child: Image.asset(
                            _currentIndex == 0
                                ? "lib/images/tabbar1_pre.png"
                                : "lib/images/tabbar1.png",
                            width: Adapt.px(40),
                            height: Adapt.px(40),
                            fit: BoxFit.fill,
                          ),
                        ),
                        label: "首页"),
                    BottomNavigationBarItem(
                        icon: Badge(
                          showBadge: false,
                          badgeContent: Text(""),
                          child: Image.asset(
                            _currentIndex == 1
                                ? "lib/images/tabbar2_pre.png"
                                : "lib/images/tabbar2.png",
                            width: Adapt.px(40),
                            height: Adapt.px(40),
                            fit: BoxFit.fill,
                          ),
                        ),
                        label: "智能数据"),
                    BottomNavigationBarItem(
                        icon: Badge(
                          showBadge: false,
                          badgeContent: Text(""),
                          child: Image.asset(
                            _currentIndex == 2
                                ? "lib/images/tabbar3_pre.png"
                                : "lib/images/tabbar3.png",
                            width: Adapt.px(40),
                            height: Adapt.px(40),
                            fit: BoxFit.fill,
                          ),
                        ),
                        label: "发现"),
                  ]),

              //配置浮动按钮的位置
            )));
  }

  void _handleSwipe() {
    final now = DateTime.now();
    if (_lastSwipeTime == null ||
        now.difference(_lastSwipeTime!) > const Duration(seconds: 1)) {
      // 如果是第一次滑动或时间间隔超过1秒，重置计数
      _swipeCount = 1;
      print("第一次滑动");
    } else {
      // 如果在1秒内滑动第二次
      _swipeCount++;
      print("第二次滑动");
    }
    _lastSwipeTime = now;

    if (_swipeCount >= 2) {
      print("退出了");
      // 如果滑动次数达到2次，退出应用
      // SystemNavigator.pop();
      if (!Platform.isIOS) _showExitConfirmationDialog();
    }
  }

  void _handleSwipe1() {
    final now = DateTime.now();
    if (_lastSwipeTime == null ||
        now.difference(_lastSwipeTime!) > const Duration(seconds: 1)) {
      // 如果是第一次滑动或时间间隔超过1秒，重置计数
      _swipeCount = 1;
      print("第一次滑动");
    } else {
      // 如果在1秒内滑动第二次
      _swipeCount++;
      print("第二次滑动");
    }
    _lastSwipeTime = now;

    if (_swipeCount >= 2) {
      print("退出了");
      // 如果滑动次数达到2次，退出应用
      // SystemNavigator.pop();
      if (!Platform.isIOS) _showExitConfirmationDialog();
    }
  }

  void _showExitConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('确认退出'),
          content: const Text('您确定要退出应用吗？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                // 关闭应用
                try {
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                } catch (e) {
                  // 如果上面的方法失败，尝试使用这个
                  SystemNavigator.pop(animated: true);
                }
              },
              child: const Text('退出'),
            ),
          ],
        );
      },
    );
  }
}
