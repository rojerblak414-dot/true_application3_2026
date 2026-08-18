import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:true_application_3/models/transaction_model.dart';

class TransactionTile extends StatelessWidget {
  TransactionTile({super.key, required this.transaction});

  final TransactionModel transaction;
  final NumberFormat _money = NumberFormat.decimalPattern();

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('d/M/yyyy').format(transaction.createdAt);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.category,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${transaction.isExpense ? '-' : '+'} ₭ ${_money.format(transaction.amount)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: transaction.isExpense ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
