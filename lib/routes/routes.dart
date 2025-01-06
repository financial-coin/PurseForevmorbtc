import 'package:get/get.dart';
import 'package:purse_for_evmorbtc/page/addWalletPage.dart';
import 'package:purse_for_evmorbtc/page/createWalletForMnemonicN.dart';
import 'package:purse_for_evmorbtc/page/mainPage/receiveCoinPage.dart';
import 'package:purse_for_evmorbtc/page/mySelfWalletN.dart';
import '../page/Login1.dart';
import '../page/FirstPage.dart';
import '../page/mainPage/accreditPage.dart';
import '../page/mainPage/myAssetsBTCPage.dart';
import '../page/splash/splash.dart';
import '../page/mySelfWallet.dart';
import '../page/createWalletForMnemonic.dart';
import '../page/mainPage/mainPage.dart';
import '../page/NetworkSelectPage.dart';
import '../page/mainPage/receivePage.dart';
import '../page/mainPage/sendPage.dart';
import '../page/mainPage/myAssetsPage.dart';
import '../page/mainPage/stakePage.dart';
import '../page/mainPage/unstakePage.dart';
import '../page/mainPage/gasExchangePage.dart';
import '../page/mainPage/financialDetailsPage.dart';
import '../page/mainPage/subscribePage.dart';
import '../page/mainPage/redemptionPage.dart';
import '../page/mainPage/redemptionNextPage.dart';
import '../page/mainPage/exchangePage.dart';
import '../page/mainPage/walletManagementPage.dart';
import '../page/mainPage/walletManagementPriPage.dart';
import '../page/mainPage/walletManagementMicPage.dart';
import '../page/WebViewPage.dart';

class AppPage {
  static final routes = [
    GetPage(name: "/Login", page: () => const Login()),
    GetPage(name: "/Splash", page: () => Splash()),
    GetPage(name: "/FirstPage", page: () => FirstPage()),
    GetPage(name: "/MySelfWallet", page: () => MySelfWallet()),
    GetPage(name: "/MySelfWalletN", page: () => MySelfWalletN()),
    GetPage(
        name: "/CreateWalletForMnemonic",
        page: () => CreateWalletForMnemonic()),
    GetPage(
        name: "/CreateWalletForMnemonicN",
        page: () => CreateWalletForMnemonicN()),
    GetPage(name: "/MainPage", page: () => MainPage()),
    GetPage(name: "/NetworkSelectPage", page: () => NetworkSelectPage()),
    GetPage(
      name: '/ReceivePage',
      page: () => ReceivePage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/SendPage',
      page: () => SendPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/MyAssetsPage',
      page: () => MyAssetsPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/StakePage',
      page: () => StakePage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/UnstakePage',
      page: () => UnstakePage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/GasExchangePage',
      page: () => GasExchangePage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/FinancialDetailsPage',
      page: () => FinancialDetailsPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/SubscribePage',
      page: () => SubscribePage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/RedemptionPage',
      page: () => RedemptionPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/RedemptionNextPage',
      page: () => RedemptionNextPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/ExchangePage',
      page: () => ExchangePage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/WalletManagementPage',
      page: () => WalletManagementPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/WalletManagementPriPage',
      page: () => WalletManagementPriPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/WebViewPage',
      page: () => WebViewPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/MyAssetsBTCPage',
      page: () => MyAssetsBTCPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/WalletManagementMicPage',
      page: () => WalletManagementMicPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/ReceiveCoinPage',
      page: () => ReceiveCoinPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/AddWalletPage',
      page: () => AddWalletPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/AccreditPage',
      page: () => AccreditPage(),
      transition: Transition.rightToLeft,
    ),
  ];
}
