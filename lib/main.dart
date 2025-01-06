// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:purse_for_evmorbtc/routes/routes.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:purse_for_evmorbtc/controllers/network_controller.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized(); // 确保Flutter绑定初始化

//   // 初始化 NetworkController
//   Get.put(NetworkController(), permanent: true);

//   if (window.physicalSize.isEmpty) {
//     print("window size is zero");
//     window.onMetricsChanged = () async {
//       if (!window.physicalSize.isEmpty) {
//         window.onMetricsChanged = null;
//         print("window onMetricsChanged,run app");
//         await initApp();
//       }
//     };
//   } else {
//     print("window load success,run app");
//     initApp();
//   }
// }

// Future<void> initApp() async {
//   await WidgetsFlutterBinding.ensureInitialized();
//   try {
//     // 初始化 SharedPreferencesance();
//     print(
//         "window:  ${window.physicalSize.width}  ${window.physicalSize.height}");
//     runApp(const MyApp());
//   } catch (e) {
//     print('初始化错误: $e');
//     runApp(const MyApp()); // 即使出错也运行应用
//   }
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
//         overlays: [SystemUiOverlay.top]);
//     return GetMaterialApp(
//       color: Colors.white,
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         backgroundColor: Colors.white,
//         primarySwatch: Colors.blue,
//       ),
//       initialRoute:
//           "/Splash", //getWallets() ? "/FirstPage" : "/MainPage", //"/FirstPage", //
//       getPages: AppPage.routes,
//     );
//   }
// }

// ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purse_for_evmorbtc/routes/routes.dart';

import 'controllers/network_controller.dart'; // 如果你使用 GetX

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // 确保 Flutter 绑定初始化
  // 初始化 NetworkController
  Get.put(NetworkController(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    return GetMaterialApp(
      // 如果使用 GetX
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        backgroundColor: Colors.white, // 确保背景颜色设置
      ),
      initialRoute: "/Splash", //"/Login", //"/Splash",
      getPages: AppPage.routes, // 确保有一个有效的主页
    );
  }
}

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class TokenBalanceChecker extends StatefulWidget {
//   @override
//   _TokenBalanceCheckerState createState() => _TokenBalanceCheckerState();
// }

// class _TokenBalanceCheckerState extends State<TokenBalanceChecker> {
//   String balance = '';
//   String balance1 = "";
//   final String address =
//       '0x5e96dc0c4a3c0cdeea7f8d45451d8804a0659349'; // 替换为你的地址
//   final String tokenAddress =
//       '0xf98BC3483c618b82B16367B606Cc3467E049B865'; // 替换为代币合约地址

//   Future<void> fetchTokenBalance() async {
//     final response = await http.post(
//       Uri.parse('https://rpc-amoy.polygon.technology'),
//       headers: {
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode({
//         'jsonrpc': '2.0',
//         'method': 'eth_call',
//         'params': [
//           {
//             'to': tokenAddress,
//             'data': '0x70a08231000000000000000000000000' +
//                 address.replaceFirst('0x', ''),
//           },
//           'latest'
//         ],
//         'id': 1,
//       }),
//     );

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = jsonDecode(response.body);
//       String balanceHex = data['result'];
//       // 将十六进制余额转换为十进制
//       BigInt balanceInWei =
//           BigInt.parse(balanceHex.replaceFirst('0x', ''), radix: 16);
//       setState(() {
//         balance = balanceInWei.toString(); // 余额以 Wei 为单位
//       });
//     } else {
//       print('Failed to load token balance');
//     }
//   }

//   Future<void> fetchBalance() async {
//     final String address =
//         '0x5e96dc0c4a3c0cdeea7f8d45451d8804a0659349'; // 替换为你的地址
//     final response = await http.post(
//       Uri.parse('https://rpc-amoy.polygon.technology'),
//       headers: {
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode({
//         'jsonrpc': '2.0',
//         'method': 'eth_getBalance',
//         'params': [address, 'latest'],
//         'id': 1,
//       }),
//     );

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = jsonDecode(response.body);
//       String balanceHex = data['result'];
//       // 将十六进制余额转换为十进制
//       BigInt balanceInWei =
//           BigInt.parse(balanceHex.replaceFirst('0x', ''), radix: 16);
//       setState(() {
//         balance1 = balanceInWei.toString(); // 余额以 Wei 为单位
//       });
//     } else {
//       print('Failed to load balance');
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     fetchTokenBalance(); // 在初始化时查询代币余额
//     fetchBalance();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('查询代币余额'),
//       ),
//       body: Center(
//         child: Column(
//           children: [
//             Text(
//               '代币余额: $balance Wei',
//               style: TextStyle(fontSize: 24),
//             ),
//             Text(
//               'MATIC余额: $balance1 Wei',
//               style: TextStyle(fontSize: 24),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// void main() {
//   runApp(MaterialApp(
//     home: TokenBalanceChecker(),
//   ));
// }
