import 'package:flutter/foundation.dart';

import '../tools/constants.dart';

class Api {
  static String baseUrl = "https://devnet-financial.qday.ninja";

  static initBaseUrl() async {
    baseUrl = isProduction ? "" : "https://devnet-financial.qday.ninja";
  }

  // 获取产品列表
  static const defiListUrl = '/financial/defi/list/chain/';
  // 获取交易列表
  static const txListUrl = '/financial/tx/list';

  static const balanceUrl = '/financial/user/balance/';

  // 获取用户资产
  static const assetsUrl = '/financial/user/assets/';

  // 获取用户资产
  static const createUrl = '/financial/user/create';

  // 获取用户btc资产
  static const btcBalanceUrl = '/financial/user/btc/balance/';

  // 获取用户btc资产
  static const btcAssetsUrl = '/financial/user/btc/assets/';
}
