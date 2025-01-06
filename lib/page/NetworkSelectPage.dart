import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purse_for_evmorbtc/tools/Adapt.dart';

class NetworkSelectPage extends StatefulWidget {
  @override
  _NetworkSelectPageState createState() => _NetworkSelectPageState();
}

class _NetworkSelectPageState extends State<NetworkSelectPage> {
  final List<Map<String, dynamic>> networks = [
    {
      'name': 'Bitcoin',
      'icon': 'lib/images/ic_Bitcoin.png',
      'isSelected': false,
    },
    {
      'name': 'Ethereum',
      'icon': 'lib/images/ETH.png',
      'isSelected': false,
    },
  ];

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
        centerTitle: true,
        title: Text(
          '切换网络',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // 编辑功能
            },
            child: Text(
              '',
              style: TextStyle(
                color: Color(0xFF6A4CFF),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索框
          // Padding(
          //   padding: EdgeInsets.symmetric(
          //     horizontal: Adapt.px(20),
          //     vertical: Adapt.px(16),
          //   ),
          //   child: Container(
          //     decoration: BoxDecoration(
          //       color: Color(0xFF1C1259),
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //     child: TextField(
          //       style: TextStyle(color: Colors.white),
          //       decoration: InputDecoration(
          //         hintText: '搜索主网',
          //         hintStyle: TextStyle(
          //           color: Colors.white.withOpacity(0.5),
          //           fontSize: 16,
          //         ),
          //         prefixIcon: Icon(
          //           Icons.search,
          //           color: Colors.white.withOpacity(0.5),
          //         ),
          //         border: InputBorder.none,
          //         contentPadding: EdgeInsets.symmetric(
          //           horizontal: 16,
          //           vertical: 12,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          // 网络列表
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: Adapt.px(20)),
              itemCount: networks.length,
              itemBuilder: (context, index) {
                final network = networks[index];
                return Container(
                  margin: EdgeInsets.only(bottom: Adapt.px(12)),
                  decoration: BoxDecoration(
                    color: network['isSelected']
                        ? Color(0xFF1C1259)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: Adapt.px(16),
                      vertical: Adapt.px(4),
                    ),
                    leading: Image.asset(
                      network['icon'],
                      width: Adapt.px(32),
                      height: Adapt.px(32),
                    ),
                    title: Text(
                      network['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: network['isSelected']
                        ? const Icon(
                            Icons.check_circle,
                            color: Color(0xFF6A4CFF),
                            size: 24,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        for (var net in networks) {
                          net['isSelected'] = false;
                        }
                        networks[index]['isSelected'] = true;
                      });
                      Get.back(result: network['name']);
                    },
                  ),
                );
              },
            ),
          ),
          // 添加网络按钮
          // Padding(
          //   padding: EdgeInsets.all(Adapt.px(20)),
          //   child: Container(
          //     width: double.infinity,
          //     height: Adapt.px(50),
          //     child: ElevatedButton(
          //       onPressed: () {
          //         // 添加网络功能
          //       },
          //       style: ElevatedButton.styleFrom(
          //         primary: Color(0xFF6A4CFF),
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(8),
          //         ),
          //       ),
          //       child: Text(
          //         '+ 添加网络',
          //         style: TextStyle(
          //           color: Colors.white,
          //           fontSize: 16,
          //           fontWeight: FontWeight.w500,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
