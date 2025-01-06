import 'package:flutter/material.dart';

class CurrencySelector extends StatelessWidget {
  final String selectedCurrency;
  final List<String> currencies;
  final ValueChanged<String?> onChanged;

  const CurrencySelector({
    Key? key,
    required this.selectedCurrency,
    required this.currencies,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blueGrey[900],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // 这里可以添加图标
              Image.asset(
                'lib/images/ETH.png', // 替换为 ETH 图标的路径
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 8),
              Text(
                selectedCurrency,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white),
        ],
      ),
    );
  }
}
