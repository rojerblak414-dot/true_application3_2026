import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FinanceSummaryRow extends StatelessWidget {
  FinanceSummaryRow({
    super.key,
    required this.income,
    required this.expense,
    required this.onIncomeTap,
    required this.onExpenseTap,
  });

  final double income;
  final double expense;
  final VoidCallback onIncomeTap;
  final VoidCallback onExpenseTap;
  final NumberFormat _money = NumberFormat.decimalPattern();

  @override
  Widget build(BuildContext context) {
    final total = income - expense;
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onIncomeTap,
            child: _FinanceInfo(
              title: 'Income',
              amount: '+ ₭ ${_money.format(income)}',
              color: Colors.green,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: onExpenseTap,
            child: _FinanceInfo(
              title: 'Expenses',
              amount: '- ₭ ${_money.format(expense)}',
              color: Colors.red,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _FinanceInfo(
            title: 'Total',
            amount: '${total >= 0 ? '+' : '-'} ₭ ${_money.format(total.abs())}',
            color: total >= 0 ? Colors.blue : Colors.red,
          ),
        ),
      ],
    );
  }
}

class _FinanceInfo extends StatelessWidget {
  const _FinanceInfo({
    required this.title,
    required this.amount,
    required this.color,
  });

  final String title;
  final String amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          FittedBox(
            child: Text(
              amount,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
