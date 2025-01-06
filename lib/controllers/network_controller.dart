import 'package:get/get.dart';

class NetworkController extends GetxController {
  final _network = 'Ethereum'.obs;
  final _account = 'Account1'.obs;
  final _isBalanceVisible = true.obs;
  var isNetworkChanged = false.obs; // 可观察的网络变化状态

  String get network => _network.value;
  String get account => _account.value;
  bool get isBalanceVisible => _isBalanceVisible.value;

  void updateNetwork(String newNetwork) {
    _network.value = newNetwork;
    isNetworkChanged.value = true; // 更新网络变化状态
  }

  void updateAccount(String newAccount) {
    _account.value = newAccount;
    isNetworkChanged.value = true; // 更新网络变化状态
  }

  void setAccount(String switchAccount) {
    _account.value = switchAccount;
    isNetworkChanged.value = true;
  }

  void toggleBalanceVisibility() {
    _isBalanceVisible.value = !_isBalanceVisible.value;
  }

  @override
  void onInit() {
    super.onInit();
  }
}
