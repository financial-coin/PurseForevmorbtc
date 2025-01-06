import 'package:flutter/material.dart';
import 'package:purse_for_evmorbtc/tools/Adapt.dart';

class CustomAppBar extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  CustomAppBar({required this.currentPage, required this.pageCount});

  @override
  Widget build(BuildContext context) {
    // 获取设备的屏幕信息
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final appBarHeight = isIOS ? 150.0 : 99.0; // iOS 和 Android 的头部高度

    return Container(
      height: appBarHeight, // 设置头部高度
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Color(0xFF110A3A), // 背景颜色
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Image.asset('lib/images/ic_return.png'), // 替换为你的图片路径
            onPressed: () {
              Navigator.pop(context); // 返回上一个页面
            },
          ),
          _buildIndicator(),
          SizedBox(width: Adapt.px(100)),
        ],
      ),
    );
  }

  Widget _buildIndicator() {
    return Row(
      children: List.generate(pageCount, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.grey, // 默认颜色
            borderRadius: BorderRadius.circular(5), // 圆角
          ),
          child: Align(
            alignment: Alignment.centerLeft, // 默认对齐方式
            child: Container(
              width: 40, // 横条的宽度
              height: 3, // 横条的高度
              decoration: BoxDecoration(
                color: currentPage >= index
                    ? Colors.white
                    : Colors.grey, // 根据当前页面的颜色
                borderRadius: BorderRadius.circular(2), // 圆角
              ),
            ),
          ),
        );
      }),
    );
  }
}
