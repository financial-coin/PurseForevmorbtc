import 'dart:convert' as convert;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:purse_for_evmorbtc/tools/Adapt.dart';
import 'package:purse_for_evmorbtc/http/api.dart';
import 'package:purse_for_evmorbtc/http/dio_utils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';

//-------
import 'package:web3dart/web3dart.dart';
import 'package:flutter_bitcoin/flutter_bitcoin.dart' as bitcoin;
import 'package:bip39/bip39.dart' as bip39;
import 'package:hex/hex.dart' show HEX; // 导入 HEX 常量
import 'package:purse_for_evmorbtc/tools/WalletBalance.dart';
import 'package:web3dart/crypto.dart';
import 'package:convert/convert.dart';
import 'package:http/http.dart' as http;
import 'package:purse_for_evmorbtc/tools/WalletRestore.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<Login> {
  TextEditingController userController = TextEditingController();
  TextEditingController pwdController = TextEditingController();

  bool showLoading = true;
  // EventBus myEventBus = EventBus();
  // var getData;
  String _code = '';
  String _message = "";

  String? mnemonic;
  String? evmAddress;
  String? btcAddress;

  // 创建钱包
  void createWallet(bool isMainnet) async {
    // 生成助记词
    mnemonic = bip39.generateMnemonic();
    print('助记词: $mnemonic');
    // 生成 EVM 钱包地址
    var seed = bip39.mnemonicToSeed(mnemonic!);
    // 使用 keccak256 哈希函数生成 32 字节的私钥
    final privateKey = keccak256(seed);

    var credentials = EthPrivateKey(privateKey);
    evmAddress = credentials.address.toString();
    print("credentials.privateKey:${credentials.privateKey}");
    final privateKeyEVMHex =
        bytesToHex(credentials.privateKey, include0x: true);

    // // 指定网络 RPC URL
    // final rpcUrl = isMainnet
    //     ? 'https://mainnet.infura.io/v3/YOUR_PROJECT_ID' // 主网
    //     : 'http://127.0.0.1:7545'; // 测试网（Sepolia）

    // // 创建 web3 客户端
    // final client = Web3Client(rpcUrl, http.Client());

    // 生成 BTC 钱包地址
    // 从 seed 生成 BTC 私钥
    final network = isMainnet ? bitcoin.bitcoin : bitcoin.testnet;
    final btcKey =
        bitcoin.ECPair.fromPrivateKey(privateKey, // 使用 seed 的前32字节作为私钥
            network: network);

    final btcPubKey = btcKey.publicKey;
    final btcPayment = bitcoin.P2PKH(
      data: bitcoin.PaymentData(pubkey: btcPubKey),
      network: network,
    );
    btcAddress = btcPayment.data.address;
    final privateBTCKeyHex = hex.encode(btcKey.privateKey);

    print('助记词: $mnemonic');
    print('EVM 地址: $evmAddress');
    print('EVM 私钥: $privateKeyEVMHex');
    print('BTC 地址: $btcAddress');
    print('BTC 私钥: $privateBTCKeyHex');
    print('BTC WIF: ${btcKey.toWIF()}'); // WIF格式的私钥

    print('EVM Address: $evmAddress');
    print('BTC Address: $btcAddress');

    // 查询余额
    final walletBalance = WalletBalance();
//调用发送btc
    // testBTCTransfer();

    final btcBalance = await walletBalance.getBTCBalance(
        "0x5e96dc0c4a3c0cdeea7f8d45451d8804a0659349", isMainnet);
    print('BTC 余额: $btcBalance  BTC');

    // final evmBalance = await walletBalance.getEVMBalance(evmAddress!);
    final evmBalance = await walletBalance.getEVMBalance(
        "0x6e1b3a03c44c56bd9990c8940c9eaf8b2ade8e9e"); // 使用 Ganache 中的地址
    print('EVM 余额: $evmBalance ETH');

    // 记得关闭客户端
    // client.dispose();
  }

  // 查询交易历史
  void checkTransactionHistory() async {
    try {
      final walletBalance = WalletBalance();

      // 查看 EVM 交易历史
      print('\n获取 EVM 交易历史...');
      final evmTxs = await walletBalance.getEVMTransactions(
          '0xd3b245908ceDD0eae7032dDbb200987d714255Eb' // 你的 EVM 地址
          );

      if (evmTxs.isEmpty) {
        print('没有 EVM 交易记录');
      } else {
        print('\nEVM 交易记录:');
        for (var tx in evmTxs) {
          print('''
交易类型: ${tx['type']}
交易哈希: ${tx['hash']}
发送方: ${tx['from']}
接收方: ${tx['to']}
金额: ${tx['value']} ETH
状态: ${tx['status']}
Gas 使用: ${tx['gasUsed']}
时间: ${tx['timestamp']}
''');
        }
      }
    } catch (e) {
      print('查询交易历史失败: $e');
    }
  }

// ETC 交易
  void testTransfer() async {
    final walletBalance = WalletBalance();

    // 发送方私钥（从 Ganache 获取）
    final privateKey =
        '0x30248383346c2da3e59e94f896f570f7260038b79fdc5a72f57fe048614c2f73';
    // 接收方地址
    final toAddress = '0x6e1b3a03c44c56bd9990c8940c9eaf8b2ade8e9e';

    // 发送交易
    final txHash = await walletBalance.sendTransaction(
        fromPrivateKey: privateKey,
        toAddress: toAddress,
        amount: 1.0, // 转账 1 ETH
        currency: "ETH");

    if (txHash != null) {
      // 等待几秒让交易被确认
      await Future.delayed(Duration(seconds: 2));

      // 检查交易状态
      final success = await walletBalance.getTransactionStatus(txHash);
      if (success) {
        print('EVM 转账成功！');
      } else {
        print('EVM 转账失败！');
      }
    }
  }

  // BTC 交易
  void testBTCTransfer() async {
    final walletBalance = WalletBalance();

    // 发送方信息
    final fromAddress = 'msoCQre58di4FEAzdQUVDaarRV7G55xjN7'; // 你的地址
    final privateKeyWIF =
        'cRSXjmdLfNB7UA74fBjznqb1KzxtchgXoz6sYRFxeoCy9QzwJNb7'; // 需要填入对应的私钥

    // 接收方地址
    final toAddress = 'mpnkqDEnNKS18o6TEBMGzh16uVVPYAkzNg'; // 目标地址

    // 先检查余额
    print('\n检查当前余额...');
    await walletBalance.checkBTCStatus(fromAddress, true);

    try {
      // 发送交易
      print('\n开始构建交易...');
      final txHash = await walletBalance.sendBTCTransaction(
          fromAddress: fromAddress,
          privateKeyWIF: privateKeyWIF,
          toAddress: toAddress,
          amount: 0.00001, // 转 0.00001 BTC
          isTestnet: true);

      if (txHash != null) {
        print('\n交易已广播!');
        print('交易哈希: $txHash');
        print('查看交易: https://mempool.space/testnet/tx/$txHash');
      } else {
        print('\n交易广播失败，请重试');
      }
    } catch (e) {
      print('\n转账失败: $e');
    }
  }

  @override
  initState() {
    // TODO: implement initState

    super.initState();
    // testTransfer();
    createWallet(false);

    // Api.initBaseUrl();
    // // HttpUtils.setBaseUrl();
    // getData();
    // setVersion();
  }

  void updateMessage(String message) {
    setState(() {
      _message = message;
    });
  }

  setVersion() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('version', "1.0.4");
  }

  login() async {
    // final walletRestore = WalletRestore();
    //通过助记词 导出钱包
    // final map = await WalletRestore.restoreFromMnemonic(
    //     "puppy tobacco employ pottery bunker urban squeeze private catch awful fog hour");
    // print('map: $map');

    // 通过私钥 导出钱包
    // final map = await WalletRestore.restoreFromPrivateKey(
    //     "0x1418977ddb3dacd048ddbd3b91a861980a302d79624ccffb64bfd1905880f29d",
    //     "2e8da49477fc3115140bb8cdca084acbafb76f6bc2b18da11ad7aaa483264891",
    //     "cNFmNGFMkcSKwbfGJJTJ1wbwzMAFTpzcFeTNsCAvmYN1NcRt78XN",
    //     false);

    // print('map: $map');

    //查询账号交易记录-EVM
    // 0xa83114A443dA1CecEFC50368531cACE9F37fCCcb
    // checkTransactionHistory();

    //查询账号交易记录-BTC
    // msoCQre58di4FEAzdQUVDaarRV7G55xjN7
    // 查询余额
    // final walletBalance = WalletBalance();
    // final btcList = await walletBalance
    //     .getBTCTestnetTransactions("msoCQre58di4FEAzdQUVDaarRV7G55xjN7");

    // print('btcTxs: $btcList');
  }

  bool isMissedDate(String date) {
    DateTime eventDate = DateTime.parse(date);
    DateTime currentDate = DateTime.now();

    return eventDate.isAfter(currentDate);
  }

  setIPOrPost() {
    Get.toNamed('/SetIpOrPort', arguments: {"data": 1});
  }

  setData(Map map) async {
    // Obtain shared preferences.
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Save an integer value to 'counter' key.
    await prefs.setString('username', userController.text);
    await prefs.setString('pwd', pwdController.text);
    await prefs.setString('UserId', map["UserId"]);
    await prefs.setString('Name', map["UserName"]);
    await prefs.setString('LoginToken', map["LoginToken"]);
    await prefs.setString('DutyId', map["DutyId"]);
    await prefs.setString('workShopId',
        map["workShopId"] == null ? "" : map["workShopId"].toString()); //车间ID
    await prefs.setString(
        'lineSectionId',
        map["lineSectionId"] == null
            ? ""
            : map["lineSectionId"].toString()); //工段ID
    await prefs.setString(
        'workShopName',
        map["workShopName"] == null
            ? ""
            : map["workShopName"].toString()); //车间ID
    await prefs.setString(
        'lineSectionName',
        map["lineSectionName"] == null
            ? ""
            : map["lineSectionName"].toString()); //工段ID
    // 工序processName: , processId: 0,
    await prefs.setString('processName', map["processName"]);
    await prefs.setString(
        'processId', map["processId"] == 0 ? "" : map["processId"].toString());
    await prefs.setString(
        'shiftId', map["shiftId"] == null ? "" : map["shiftId"].toString());
    await prefs.setString('workGroupId',
        map["workGroupId"] == null ? "" : map["workGroupId"].toString());
    await prefs.setString(
        'lineId', map["lineId"] == null ? "" : map["lineId"].toString());

    await prefs.setString('ypOrzjx', "0"); //0样品 1质检项
  }

  getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('username');
    final String? pwd = prefs.getString('pwd');

    final String? IP = prefs.getString('IP');
    final String? Port = prefs.getString('Port');

    if (IP == null || Port == null) {
      Get.toNamed('/SetIpOrPort', arguments: {"data": 1});
    }

    userController.text = username ?? "";
    pwdController.text = pwd ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
        child: MaterialApp(
            home: Scaffold(
                body: SingleChildScrollView(
      child: Container(
        width: Adapt.px(750),
        height: Adapt.screenH(),
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
              width: Adapt.px(750),
              height: Adapt.px(280),
              alignment: Alignment.topLeft,
              padding: EdgeInsets.fromLTRB(Adapt.px(48), Adapt.px(150), 0, 0),
              // child: Image.asset('img/kcLogo.png', height: 284, width: 85),
            ),
            Container(
              width: Adapt.px(750),
              height: Adapt.px(100),
              alignment: Alignment.topLeft,
              // color: Colors.red,
              padding: EdgeInsets.fromLTRB(Adapt.px(48), Adapt.px(12), 0, 0),
              child: Text('您好，欢迎登录！',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: Adapt.px(52),
                      color: const Color.fromRGBO(31, 31, 57, 1),
                      fontWeight: FontWeight.w400),
                  textDirection: TextDirection.ltr),
            ),
            Container(
              width: Adapt.px(750),
              height: Adapt.px(55),
              alignment: Alignment.topLeft,
              padding: EdgeInsets.fromLTRB(Adapt.px(48), Adapt.px(0), 0, 0),
              child: Text('请使用账号密码登录',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: Adapt.px(32),
                      color: const Color.fromRGBO(181, 181, 181, 1),
                      fontWeight: FontWeight.w400),
                  textDirection: TextDirection.ltr),
            ),
            Container(
              width: Adapt.px(750),
              height: Adapt.px(55),
              alignment: Alignment.topLeft,
              padding: EdgeInsets.fromLTRB(Adapt.px(48), Adapt.px(0), 0, 0),
              margin: EdgeInsets.fromLTRB(0, Adapt.px(96), 0, 0),
              child: Text('用户名',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: Adapt.px(36),
                      color: const Color.fromRGBO(31, 31, 57, 1),
                      fontWeight: FontWeight.w400),
                  textDirection: TextDirection.ltr),
            ),
            Container(
                width: Adapt.px(654),
                height: Adapt.px(100),
                alignment: Alignment.topLeft,
                padding: EdgeInsets.fromLTRB(Adapt.px(0), Adapt.px(0), 0, 0),
                margin: EdgeInsets.fromLTRB(0, Adapt.px(0), 0, 0),
                child: TextField(
                  controller: userController,
                  decoration: InputDecoration(
                    hintText: "请输入用名",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        userController.clear();
                      },
                    ),
                  ),
                )),
            Container(
              width: Adapt.px(750),
              height: Adapt.px(55),
              alignment: Alignment.topLeft,
              padding: EdgeInsets.fromLTRB(Adapt.px(48), Adapt.px(0), 0, 0),
              margin: EdgeInsets.fromLTRB(0, Adapt.px(32), 0, 0),
              child: Text('密码',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: Adapt.px(36),
                      color: const Color.fromRGBO(31, 31, 57, 1),
                      fontWeight: FontWeight.w400),
                  textDirection: TextDirection.ltr),
            ),
            Container(
                width: Adapt.px(654),
                height: Adapt.px(100),
                alignment: Alignment.topLeft,
                padding: EdgeInsets.fromLTRB(Adapt.px(0), Adapt.px(0), 0, 0),
                // margin: EdgeInsets.fromLTRB(0, Adapt.px(96), 0, 0),
                child: TextField(
                  keyboardType: TextInputType.text,
                  controller: pwdController,
                  obscureText: true, // 内容不可见
                  decoration: InputDecoration(
                    hintText: "请输入密码",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        pwdController.clear();
                      },
                    ),
                  ),
                )),
            Container(
                width: Adapt.px(750),
                height: Adapt.px(55),
                margin: EdgeInsets.fromLTRB(0, Adapt.px(20), Adapt.px(50), 0),
                child: InkWell(
                    onTap: () => setIPOrPost(),
                    child: Text('设置IP',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            decoration: TextDecoration.none,
                            fontSize: Adapt.px(40),
                            color: const Color.fromRGBO(48, 98, 238, 1),
                            fontWeight: FontWeight.w400),
                        textDirection: TextDirection.ltr))),
            GestureDetector(
                onTap: () => login(),
                child: Container(
                  width: Adapt.px(622),
                  height: Adapt.px(88),
                  alignment: Alignment.center,
                  padding: EdgeInsets.fromLTRB(Adapt.px(0), Adapt.px(0), 0, 0),
                  margin: EdgeInsets.fromLTRB(0, Adapt.px(96), 0, 0),
                  // onPressed: () {},
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(44)),
                      gradient: LinearGradient(
                          //渐变位置
                          begin: Alignment.topRight, //右上
                          end: Alignment.bottomLeft, //左下
                          stops: [
                            0.0,
                            1.0
                          ], //[渐变起始点, 渐变结束点]
                          //渐变颜色[始点颜色, 结束颜色]
                          colors: [
                            Color.fromRGBO(99, 157, 255, 1),
                            Color.fromRGBO(48, 98, 238, 1)
                          ])),

                  child: Text('登录',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          decoration: TextDecoration.none,
                          fontSize: Adapt.px(40),
                          color: const Color.fromRGBO(255, 255, 255, 1),
                          fontWeight: FontWeight.w400),
                      textDirection: TextDirection.ltr),
                )),
          ],
        ),
      ),
    ))));
  }

  showLoadingFun() {
    setState(() {
      showLoading = true;
    });
    showDialog(
        barrierDismissible: showLoading,
        context: context,
        builder: (BuildContext context) {
          return Container(
            color: Colors.transparent,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                width: 230,
                height: 140,
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SpinKitFadingCircle(
                      color: Colors.black,
                      size: 46,
                    ),
                    Container(height: 18),
                    const Text('正在检测更新',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            decoration: TextDecoration.none,
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                        textDirection: TextDirection.ltr)
                  ],
                ),
              ),
            ),
          );
        });
  }

  customParseJson(String? json) {}
}
