import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purse_for_evmorbtc/tools/Adapt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import '../http/api.dart';
import '../http/dio_utils.dart';
import '../tools/CustomAppBar.dart';
import 'dart:math';
import 'package:get/get.dart';
import 'package:bip39/bip39.dart' as bip39;
import '../tools/WalletRestore.dart';
import '../tools/WalletStorage.dart';
import '../tools/constants.dart';
import 'package:flutter_bitcoin/flutter_bitcoin.dart' as bitcoin;
import 'package:http/http.dart' as http;

class MySelfWalletN extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _MySelfWalletNPageState createState() => _MySelfWalletNPageState();
}

class _MySelfWalletNPageState extends State<MySelfWalletN> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int pageCount = 4;
  bool _isChecked = false; // 定义复选框的状态

  bool _isPasswordVisible = false; // 控制密码可见性
  bool _isPasswordVisible2 = false; // 控制密码可见性
  bool _isChecked2 = false; // 定义复选框的状态
  List<String> words = [
    'grain',
    'satisfy',
    'since',
    'doll',
    'neutral',
    'brick',
    'riot',
    'swarm',
    'piano',
    'primary',
    'kite',
    'income'
  ];
  List<Map> point = [
    {"x": 0, "y": 10},
    {"x": 300, "y": 10},
    {"x": 150, "y": 100},
    {"x": 450, "y": 100},
    {"x": 0, "y": 200},
    {"x": 300, "y": 200},
    {"x": 150, "y": 300},
    {"x": 450, "y": 300},
    {"x": 0, "y": 400},
    {"x": 300, "y": 400},
    {"x": 150, "y": 500},
    {"x": 450, "y": 500},
  ];

  String? firstSelected;
  String? lastSelected;
  String wordValue = "";
  String? mnemonic = "";
  String? evmAddress = "";
  String? evmPrivateKey = "";
  String? btcAddress = "";
  String? btcPrivateKey = "";
  String? btcWif = "";

  bool flag = false;
  String password = '';
  String confirmPassword = '';
  String errorMessage = '';
  String? keyName = "";

  @override
  void initState() {
    super.initState();
    // _shuffleWords(); // 在初始化时打乱单词顺序
    _getNextAccountName();
  }

  //生成key的方法
  Future<String> _getNextAccountName() async {
    final wallets = await WalletStorage.getWallets();
    print(wallets);
    if (wallets.isEmpty) {
      setState(() {
        keyName = "Account1";
      });
      print("----1:" + keyName!);
      return 'Account1';
    }
    // 获取现有账号数量
    print("----2:" + keyName!);
    int maxNumber = 0;
    for (String key in wallets.keys) {
      if (key.startsWith('Account')) {
        int? number = int.tryParse(key.substring(7));
        if (number != null && number > maxNumber) {
          maxNumber = number;
        }
      }
    }
    print("----3:" + maxNumber.toString());
    setState(() {
      keyName = 'Account${maxNumber + 1}';
    });
    print("----4:" + keyName!);
    return 'Account${maxNumber + 1}';
  }

  void _shuffleWords() {
    List<String> wordsCopy = List.from(words); // 创建一个副本
    wordsCopy.shuffle(Random()); // 随机打乱副本的顺序
    setState(() {
      words = wordsCopy; // 更新原始列表
      // mnemonicWords = wordsCopy; // 如果需要，可以更新 mnemonicWords
    });
  }

  void _selectWord(String word) {
    setState(() {
      if (firstSelected == null) {
        firstSelected = word; // 选择第一个单词
      } else if (lastSelected == null && word != firstSelected) {
        lastSelected = word; // 选择最后一个单词
      } else {
        // 如果已经选择了两个单词，重置选择
        firstSelected = null;
        lastSelected = null;
      }
    });
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  selectPrivateKey() {
    _nextPage();
    print('selectPrivateKey');
  }

  walletImport() async {
    //flutter: EVM 私钥位数66
    // flutter: BTC 私钥位数64
    // flutter: BTC WIF 位数52
    List<String> wordsList = wordValue.split(' '); // 按空格分割字符串
    if (wordsList.length == 12) {
      print('助记词');
      final map = await WalletRestore.restoreFromMnemonic(wordValue);
      print('map: $map');

      setState(() {
        mnemonic = map['mnemonic'];
        evmAddress = map['evmAddress'];
        evmPrivateKey = map['evmPrivateKey'];
        btcAddress = map['btcAddress'];
        btcPrivateKey = map['btcPrivateKey'];
        btcWif = map['btcWif'];
        words = wordsList;
      });

      // final SharedPreferences prefs = await SharedPreferences.getInstance();
      // await prefs.setString('evmAddress', evmAddress!);
      // await prefs.setString('evmPrikey', evmPrivateKey!);
      // await prefs.setString('btcAddress', btcAddress!);
      // await prefs.setString('btcPrikey', btcPrivateKey!);
      // await prefs.setString('btcWIF', btcWif!);

      _shuffleWords();
      _nextPage();
    } else {
      if (wordValue.length == 66 || wordValue.length == 64) {
        if (wordValue.length == 64) {
          wordValue = "0x$wordValue";
        }
        print('EVM 私钥位数66');
        final map = await WalletRestore.restoreFromPrivateKeyETH(wordValue);
        print('map: $map');

        String? mnemonicW = bip39.generateMnemonic();
        print('助记词: $mnemonicW');
        List<String> wordsList = mnemonicW.split(' '); // 按空格分割字符串
        setState(() {
          words = wordsList;
        });
        // 生成 EVM 钱包地址
        var seed = bip39.mnemonicToSeed(mnemonicW);
        // 使用 keccak256 哈希函数生成 32 字节的私钥
        final privateKey = keccak256(seed);
        // 从 seed 生成 BTC 私钥
        final network = isProduction ? bitcoin.bitcoin : bitcoin.testnet;
        final btcKey =
            bitcoin.ECPair.fromPrivateKey(privateKey, // 使用 seed 的前32字节作为私钥
                network: network);

        final btcPubKey = btcKey.publicKey;
        final btcPayment = bitcoin.P2PKH(
          data: bitcoin.PaymentData(pubkey: btcPubKey),
          network: network,
        );
        String? btcAddress1 = btcPayment.data.address;
        final privateBTCKeyHex = hex.encode(btcKey.privateKey);
        setState(() {
          mnemonic = mnemonicW;
          evmAddress = map['evmAddress'];
          evmPrivateKey = map['evmPrivateKey'];
          btcAddress = btcAddress1;
          btcPrivateKey = privateBTCKeyHex;
          btcWif = btcKey.toWIF();
          words = wordsList;
        });
        // final SharedPreferences prefs = await SharedPreferences.getInstance();
        // await prefs.setString('evmAddress', evmAddress!);
        // await prefs.setString('evmPrikey', evmPrivateKey!);
        // await prefs.setString('btcAddress', btcAddress!);
        // await prefs.setString('btcPrikey', btcPrivateKey!);
        // await prefs.setString('btcWIF', btcWif!);

        _shuffleWords();
        _nextPage();
      } else if (wordValue.length == 52) {
        print('BTC 私钥位数64');
        print('BTC WIF 位数52');
        final map;
        // if (wordValue.length == 64) {
        //   map = await WalletRestore.restoreFromPrivateKeyBTC(
        //       wordValue, "", isProduction);
        //   print('map: $map');
        //   _nextPage();
        // } else {
        map = await WalletRestore.restoreFromPrivateKeyBTC(
            "", wordValue, isProduction);
        print('map: $map');
        _nextPage();
        // }
        String? mnemonicW = bip39.generateMnemonic();
        print('助记词: $mnemonicW');
        List<String> wordsList = mnemonicW.split(' '); // 按空格分割字符串
        setState(() {
          words = wordsList;
        });

        // 生成 EVM 钱包地址
        var seed = bip39.mnemonicToSeed(mnemonicW);
        // 使用 keccak256 哈希函数生成 32 字节的私钥
        final privateKey = keccak256(seed);

        var credentials = EthPrivateKey(privateKey);
        var evmAddress1 = credentials.address.toString();
        print("credentials.privateKey:${credentials.privateKey}");
        final privateKeyEVMHex =
            bytesToHex(credentials.privateKey, include0x: true);

        setState(() {
          mnemonic = mnemonicW;
          evmAddress = evmAddress1;
          evmPrivateKey = privateKeyEVMHex;
          btcAddress = map['btcAddress'];
          btcPrivateKey = map['btcPrivateKey'];
          btcWif = map['btcWif'];
          words = wordsList;
        });

        // final SharedPreferences prefs = await SharedPreferences.getInstance();
        // await prefs.setString('evmAddress', evmAddress!);
        // await prefs.setString('evmPrikey', evmPrivateKey!);
        // await prefs.setString('btcAddress', btcAddress!);
        // await prefs.setString('btcPrikey', btcPrivateKey!);
        // await prefs.setString('btcWIF', btcWif!);

        _shuffleWords();
        _nextPage();
      }
    }
  }

  submitMnemonic() {
    print('submitMnemonic');

    List<String> arr = mnemonic!.split(' ');
    print('firstSelected: $firstSelected');
    print('lastSelected: $lastSelected');
    print('arr[0]: ${arr[0]}');
    print('arr[11]: ${arr[11]}');

    if (arr[0] == firstSelected && arr[11] == lastSelected) {
      print('助记词正确');
      // _nextPage();setPwd
      setPwd();
    } else {
      Get.snackbar(
        '助记词错误',
        '请记住您的助记词',
        backgroundColor: Colors.red[500],
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      print('助记词错误');
    }
  }

  setPwd() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? pwd = prefs.getString('passWord');
    print('pwd: $pwd');
    await WalletStorage.updateWallet(keyName!, {
      'mnemonic': mnemonic,
      'evmAddress': evmAddress,
      'evmPrikey': evmPrivateKey,
      'btcAddress': btcAddress,
      'btcPrikey': btcPrivateKey,
      'btcWIF': btcWif,
      'passWord': pwd,
    });
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastAccount', keyName!);
    CreateE();
    CreateB();
    Get.snackbar(
      '保存成功',
      '密码保存成功',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
    Get.toNamed('/MainPage');
  }

  Future<void> CreateE() async {
    try {
      var headers = {'Content-Type': 'application/json'};
      var request =
          http.Request('POST', Uri.parse('${Api.baseUrl}${Api.createUrl}'));
      request.body = json.encode(
          {"address": evmAddress, "chainId": "1", "chainName": "Ethereum"});
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      print('${Api.baseUrl}${Api.createUrl}');
      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
      } else {
        print(response.reasonPhrase);
      }
    } catch (e) {
      print("加载数据错误: $e");
    }
  }

  Future<void> CreateB() async {
    try {
      var headers = {'Content-Type': 'application/json'};
      var request =
          http.Request('POST', Uri.parse('${Api.baseUrl}${Api.createUrl}'));
      request.body = json.encode(
          {"address": btcAddress, "chainId": "1", "chainName": "Ethereum"});
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      print('${Api.baseUrl}${Api.createUrl}');

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
      } else {
        print(response.reasonPhrase);
      }
      // final res = await HttpUtils.instance.post(
      //   Api.createUrl,
      //   params: {"address": btcAddress, "chainId": "1", "chainName": "Bitcoin"},
      //   tips: false,
      //   context: context,
      // );

      // if (res.code == 0) {
      //   // setState(() {
      //   //   // BalanceD = res.data.toString();
      //   // });
      // }
    } catch (e) {
      print("加载数据错误: $e");
    }
  }

  void _validatePasswords() {
    if (password != confirmPassword) {
      setState(() {
        flag = false;
        errorMessage = '密码不一致'; // 设置错误信息
      });
    } else {
      const passwordPattern =
          r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d).{11,20}$'; // 密码规则
      final regex = RegExp(passwordPattern);
      if (!regex.hasMatch(password)) {
        setState(() {
          flag = false;
          errorMessage = '密码必须包含数字、字母、至少一个大写字母，长度在11到20位之间。';
          // 设置错误信息
        });
      } else {
        setState(() {
          flag = true;
          errorMessage = '匹配'; // 清除错误信息
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(180.0), // 自定义导航栏高度
        child: CustomAppBar(
          currentPage: _currentPage,
          pageCount: pageCount,
        ), // 使用自定义导航栏
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: NeverScrollableScrollPhysics(), // 禁止手动滑动
              children: [
                _buildPage1('输入恢复短语或私钥', '使用 12 词恢复短语或私钥，安全导入您的钱包。'),
                _buildPage2('导入钱包',
                    '请输入您钱包的 12 词恢复短语或私钥，您可以导入任何以太坊、Solana 或比特币恢复短语，仅支持以太坊私钥'),
                // 添加其他页面内容
                _buildPage3('页面 3', '内容 3'),
                _buildPage4('页面 4', '内容 4'),
                // _buildPage5('页面 5', '内容 5'),
              ],
            ),
          ),
          //_buildIndicator(),
          // ElevatedButton(
          //   onPressed: _nextPage,
          //   child: Text('下一步'),
          // ),
        ],
      ),
    );
  }

  Widget _buildPage1(String title, String content) {
    return Container(
      color: Color(0xFF110A3A), // 背景颜色
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '使用现有钱包',
            style: TextStyle(
              color: Colors.white,
              fontSize: 33,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: Adapt.px(20)),
          const Text(
            '选择您想要访问钱包的方式：',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          SizedBox(height: Adapt.px(120)),

          _buildOptionCard(
            title: '输入恢复短语或私钥',
            description: '使用 12 词恢复短语或私钥，安全导入您的钱包。',
          ),
          // SizedBox(height: 20),
          // _buildOptionCard(
          //   title: '连接 Ledger 钱包',
          //   description: '使用 Ledger 设备进行交易（仅限以太坊）。',
          // ),
        ],
      ),
    );
  }

  Widget _buildPage2(String title, String content) {
    return Container(
      color: Color(0xFF110A3A), // 深紫色背景
      padding: EdgeInsets.all(Adapt.px(32)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '导入钱包', // 更新标题
            style: TextStyle(
              color: Colors.white,
              fontSize: 33,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: Adapt.px(20)),
          const Text(
            '请输入您钱包的 12 词恢复短语或私钥，您可以导入任何以太坊或比特币恢复短语', // 更新描述文本
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
          SizedBox(height: Adapt.px(20)),
          // 添加输入框
          Container(
            margin: EdgeInsets.fromLTRB(
                Adapt.px(16), Adapt.px(46), Adapt.px(16), 0),
            padding: EdgeInsets.fromLTRB(Adapt.px(16), 0, 0, 0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.withOpacity(0.5),
                width: 1.0,
              ),
            ),
            child: TextField(
              style: TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '填写助记词或私钥',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {
                  wordValue = value;
                });
              },
            ),
          ),
          SizedBox(height: Adapt.px(16)),
          // 添加"在哪里可以找到？"链接
          TextButton(
            onPressed: () {
              // 处理点击事件
            },
            child: const Text(
              '在哪里可以找到？',
              style: TextStyle(
                color: Color.fromRGBO(101, 74, 221, 1),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          SizedBox(height: Adapt.px(40)),
          ElevatedButton(
            onPressed: () {
              // 创建新钱包的逻辑
              // _nextPage();
//               flutter: EVM 私钥位数66
// flutter: BTC 私钥位数64
// flutter: BTC WIF 位数52
              walletImport();
              print('inputWallet 导入钱包');
            },
            style: ElevatedButton.styleFrom(
              primary: Color(0xFF6A4CFF), // 按钮颜色
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              minimumSize: Size(400, 50),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              child: Text(
                '导入钱包',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          // Spacer(),
          // 添加"导入钱包"按钮
        ],
      ),
    );
  }

  Widget _buildPage3(String title, String content) {
    return Container(
      color: Color(0xFF110A3A), // 深紫色背景
      padding: EdgeInsets.all(Adapt.px(32)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '备份您的钱包', // 更新标题
            style: TextStyle(
              color: Colors.white,
              fontSize: 33,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: Adapt.px(20)),
          const Text(
            '将这12个词保存到密码管理器中，或写下来并存放在安全之处。不要与任何人分享。', // 更新描述文本
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
          SizedBox(height: Adapt.px(20)),
          // 添加输入框

          Container(
            height: Adapt.px(200),
            margin: EdgeInsets.fromLTRB(
                Adapt.px(16), Adapt.px(46), Adapt.px(16), 0),
            padding: EdgeInsets.fromLTRB(
                Adapt.px(16), Adapt.px(16), Adapt.px(16), 0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.withOpacity(0.5),
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  mnemonic ?? "", // 显示的文本
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  maxLines: 3, // 最大行数
                  overflow: TextOverflow.visible, // 允许文本溢出
                ),
              ],
            ),
          ),
          SizedBox(height: Adapt.px(16)),

          Row(
            children: [
              const Icon(Icons.copy, color: Colors.white, size: 20),
              TextButton(
                onPressed: () {
                  // 处理点击事件
                  Clipboard.setData(ClipboardData(text: mnemonic!));
                  Get.snackbar(
                    '复制成功',
                    '助记词已复制到剪贴板',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                child: const Text(
                  '复制您的助记词',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          // 添加"在哪里可以找到？"链接

          SizedBox(height: Adapt.px(40)),

          Row(
            children: [
              Checkbox(
                value: _isChecked, // 根据需要设置复选框的初始值
                onChanged: (bool? value) {
                  // TODO: 处理复选框状态变化
                  setState(() {
                    _isChecked = value ?? false; // 更新状态
                  });
                },
                activeColor: Color(0xFF6A4CFF), // 选中时的颜色
                checkColor: Colors.white, // 选中时勾选的颜色
                side: BorderSide(color: Colors.white), // 边框颜色
              ),
              const Expanded(
                child: Text(
                  '我明白，如果丢失了恢复短语，我将丢失钱包中的所有加密货币。',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          ElevatedButton(
            onPressed: () {
              // 创建新钱包的逻辑
              _nextPage();
              print('inputWallet 备份助记词');
            },
            style: ElevatedButton.styleFrom(
              primary: Color(0xFF6A4CFF), // 按钮颜色
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              minimumSize: Size(400, 50),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              child: Text(
                '继续',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          // Spacer(),
          // 添加"导入钱包"按钮
        ],
      ),
    );
  }

  Widget _buildPage4(String title, String content) {
    // 随机生成单词的位置
    int wordCount = 0;

    List<Widget> wordWidgets = words.map((word) {
      final isFirstSelected = word == firstSelected;
      final isLastSelected = word == lastSelected;
      final isSelected = isFirstSelected || isLastSelected;
      wordCount++;
      print('wordCount: $word');
      return Positioned(
          left: Adapt.px(point[wordCount - 1]["x"]).toDouble(), // 随机 X 位置
          top: Adapt.px(point[wordCount - 1]["y"]).toDouble(), // 随机 Y 位置
          child: Stack(children: [
            GestureDetector(
              onTap: () => _selectWord(word),
              child: Container(
                padding: EdgeInsets.all(10.0),
                margin: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white
                      : Color.fromRGBO(255, 255, 255, 0.3),
                  borderRadius: BorderRadius.circular(8.0),
                  border: isFirstSelected
                      ? Border.all(color: Colors.white, width: 2)
                      : isLastSelected
                          ? Border.all(color: Colors.red, width: 2)
                          : null,
                ),
                child: Text(
                  word,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            // 添加标签
            if (isFirstSelected)
              Positioned(
                // top: -20, // 标签位置
                // left: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(0, 0, 0, 0.6),
                    borderRadius: BorderRadius.circular(8.0), // 添加圆角
                  ),
                  // color: const Color.fromRGBO(0, 0, 0, 0.6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  // decoration: BoxDecoration(
                  //   borderRadius: BorderRadius.circular(8.0),
                  // ),
                  child: const Text(
                    '第一个',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            if (isLastSelected)
              Positioned(
                // top: -20, // 标签位置
                // left: 0,

                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(0, 0, 0, 0.6),
                    borderRadius: BorderRadius.circular(8.0), // 添加圆角
                  ),
                  // color: const Color.fromRGBO(0, 0, 0, 0.6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: const Text(
                    '最后一个',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
          ]));
    }).toList();
    return Container(
      color: Color(0xFF110A3A), // 深紫色背景
      padding: EdgeInsets.all(Adapt.px(32)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '您是否已经保存？', // 更新标题
            style: TextStyle(
              color: Colors.white,
              fontSize: 33,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: Adapt.px(20)),
          const Text(
            '通过依次点击 第一个（第1个）和 最后一个（第12个）单词来验证您是否保存了密钥恢复短语。', // 更新描述文本
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
          SizedBox(height: Adapt.px(20)),
          // 使用一个固定高度的容器包裹 Stack
          Container(
            height: 400, // 设置一个固定高度
            child: Stack(
              children: wordWidgets,
            ),
          ),

          ElevatedButton(
            onPressed: () {
              // 创建新钱包的逻辑
              // _nextPage();
              submitMnemonic();
              print('inputWallet 提交助记词');
            },
            style: ElevatedButton.styleFrom(
              primary: Color(0xFF6A4CFF), // 按钮颜色
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              minimumSize: Size(400, 50),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              child: Text(
                '提交',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          // Spacer(),
          // 添加"导入钱包"按钮
        ],
      ),
    );
  }

  Widget _buildPage5(String title, String content) {
    return Scaffold(
      backgroundColor: Color(0xFF110A3A), // 深紫色背景
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '创建密码', // 更新标题
              style: TextStyle(
                color: Colors.white,
                fontSize: 33,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              '每次使用电脑时设置锁定您钱包的密码。该密码不能用于恢复您的钱包。',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            SizedBox(height: 20),
            TextField(
              obscureText: !_isPasswordVisible, // 根据状态控制可见性
              decoration: InputDecoration(
                labelText: '密码',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible; // 切换可见性
                    });
                  },
                ),
              ),
              style: TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() {
                  password = value; // 更新密码
                  _validatePasswords(); // 验证密码一致性
                });
              },
            ),
            // SizedBox(height: 10),
            // Row(
            //   children: [
            //     Container(width: 50, height: 5, color: Colors.red),
            //     SizedBox(width: 5),
            //     Container(width: 50, height: 5, color: Colors.orange),
            //     SizedBox(width: 5),
            //     Container(width: 50, height: 5, color: Colors.yellow),
            //     SizedBox(width: 5),
            //     Container(width: 50, height: 5, color: Colors.green),
            //     SizedBox(width: 5),
            //     Container(width: 50, height: 5, color: Colors.blue),
            //   ],
            // ),
            SizedBox(height: 5),
            // Text(
            //   '很好！',
            //   style: TextStyle(color: Colors.green, fontSize: 14),
            // ),
            SizedBox(height: 20),
            TextField(
              obscureText: !_isPasswordVisible2, // 根据状态控制可见性
              decoration: InputDecoration(
                labelText: '验证密码',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible2
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible2 = !_isPasswordVisible2; // 切换可见性
                    });
                  },
                ),
              ),
              style: TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() {
                  confirmPassword = value; // 更新确认密码
                  _validatePasswords(); // 验证密码一致性
                });
              },
            ),
            SizedBox(height: 20),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: TextStyle(
                    color: flag ? Colors.green : Colors.red, fontSize: 14),
              ),
            Row(
              children: [
                Checkbox(
                  value: _isChecked2, // 根据需要设置复选框的初始值
                  onChanged: (bool? value) {
                    // TODO: 处理复选框状态变化
                    setState(() {
                      _isChecked2 = value ?? false; // 更新状态
                    });
                  },
                  activeColor: Color(0xFF6A4CFF), // 选中时的颜色
                  checkColor: Colors.white, // 选中时勾选的颜色
                  side: BorderSide(color: Colors.white), // 边框颜色
                ),
                Expanded(
                    child: Row(
                  children: const [
                    Text(
                      '我同意 ',
                      style: TextStyle(color: Colors.white70),
                    ),
                    Text(
                      '条款',
                      style: TextStyle(
                        color: Color.fromRGBO(101, 74, 221, 1),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    Text(
                      ' 和 ',
                      style: TextStyle(color: Colors.white70),
                    ),
                    Text(
                      '隐私政策',
                      style: TextStyle(
                        color: Color.fromRGBO(101, 74, 221, 1),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                )),
              ],
            ),
            SizedBox(height: Adapt.px(20)),
            ElevatedButton(
              onPressed: () {
                // 创建新钱包的逻辑
                // _nextPage();
                setPwd();
                print('inputWallet 提交');
              },
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF6A4CFF), // 按钮颜色
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: Size(400, 50),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                child: Text(
                  '提交',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? Colors.blue : Colors.grey,
          ),
        );
      }),
    );
  }

  Widget _buildOptionCard(
      {required String title, required String description}) {
    return InkWell(
        onTap: () => selectPrivateKey(),
        child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, 0.2),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: Colors.white,
                width: 1.0,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: Adapt.px(350),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Adapt.px(8)),
                  SizedBox(
                    width: Adapt.px(530),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            description,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Icon(Icons.accessible_outlined,
                  color: Colors.white, size: 40),
            ])));
  }
}
