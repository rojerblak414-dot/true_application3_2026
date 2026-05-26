import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:true_application_3/component/my_builheader.dart';
import 'package:true_application_3/help/drawer.dart';
import 'package:true_application_3/income_expense_model/model.dart';
import 'package:true_application_3/support/Add_expense_page.dart';
import 'package:true_application_3/support/Add_income_page.dart';
import 'package:true_application_3/support/profile_page.dart';
// ไอคอนนำเข้าไฟล์ Model ที่แยกไว้ด้านบน

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              my_builheader(),
              const SizedBox(height: 25),
              _buildDataStream(userId),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataStream(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("expenses")
          .where("userId", isEqualTo: userId)
          .snapshots(),
      builder: (context, expenseSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("income")
              .where("userId", isEqualTo: userId)
              .snapshots(),
          builder: (context, incomeSnapshot) {
            double totalExp = 0, totalInc = 0;
            Map<String, double> categoryMap = {
              "Car": 0,
              "Internet": 0,
              "Food": 0,
            };

            List<TransactionModel> allTransactions = [];

            // จัดการข้อมูลฝั่งรายจ่ายด้วย Model
            if (expenseSnapshot.hasData) {
              for (var doc in expenseSnapshot.data!.docs) {
                final tx = TransactionModel.fromFirestore(
                  doc as DocumentSnapshot<Object?>,
                  true,
                );
                allTransactions.add(tx);
                totalExp += tx.amount;
                if (categoryMap.containsKey(tx.category)) {
                  categoryMap[tx.category] =
                      categoryMap[tx.category]! + tx.amount;
                }
              }
            }

            // จัดการข้อมูลฝั่งรายรับด้วย Model
            if (incomeSnapshot.hasData) {
              for (var doc in incomeSnapshot.data!.docs) {
                final tx = TransactionModel.fromFirestore(
                  doc as DocumentSnapshot<Object?>,
                  false,
                );
                allTransactions.add(tx);
                totalInc += tx.amount;
              }
            }

            // เรียงลำดับวันที่ผ่าน Model object
            allTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return Column(
              children: [
                _buildExpenseCard(totalExp, categoryMap),
                const SizedBox(height: 25),
                my_buildFinanceSummaryRow(
                  context: context,
                  income: totalInc,
                  expense: totalExp,
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "ທຸລະກຳລ່າສຸດ",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("ປະຫວັດ", style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
                const SizedBox(height: 15),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: allTransactions.length > 5
                      ? 5
                      : allTransactions.length,
                  itemBuilder: (context, index) {
                    final tx = allTransactions[index];
                    String dateStr =
                        "${tx.createdAt.day}/${tx.createdAt.month}/${tx.createdAt.year}";

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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx.category,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dateStr,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "${tx.isExpense ? '-' : '+'} ${tx.amount.toStringAsFixed(0)} ₭",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: tx.isExpense ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfilePage()),
          ),
          child: const Padding(
            padding: EdgeInsets.only(right: 15),
            child: CircleAvatar(radius: 20, child: Icon(Icons.person)),
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseCard(double total, Map<String, double> categories) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          // ignore: deprecated_member_use
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Expenses",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "₭ ${total.toStringAsFixed(1)}",
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 35,
                      sections: _buildPieChartSections(total, categories),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: categories.entries
                        .map(
                          (e) => _buildCategoryItem(
                            e.key,
                            "₭ ${e.value.toStringAsFixed(0)}",
                            _getCategoryColor(e.key),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    double total,
    Map<String, double> categoryMap,
  ) {
    if (total == 0) {
      return [
        PieChartSectionData(
          color: Colors.grey[200],
          value: 1,
          title: '0%',
          radius: 45,
        ),
      ];
    }
    return categoryMap.entries.where((e) => e.value > 0).map((entry) {
      return PieChartSectionData(
        color: _getCategoryColor(entry.key),
        value: entry.value,
        title: '${((entry.value / total) * 100).toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case "Car":
        return Colors.orange;
      case "Internet":
        return Colors.red;
      case "Food":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildCategoryItem(String title, String amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                amount,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ignore: camel_case_types
class my_buildFinanceSummaryRow extends StatelessWidget {
  const my_buildFinanceSummaryRow({
    super.key,
    required this.context,
    required this.income,
    required this.expense,
  });

  final BuildContext context;
  final double income;
  final double expense;

  @override
  Widget build(BuildContext context) {
    double total = income - expense;
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddIncomePage()),
            ),
            child: my_buildFinanceInfo(
              title: "Income",
              amount: "+ ₭ ${income.toStringAsFixed(0)}",
              color: Colors.green,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddExpensePage()),
            ),
            child: my_buildFinanceInfo(
              title: "Expenses",
              amount: "- ₭ ${expense.toStringAsFixed(0)}",
              color: Colors.red,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: my_buildFinanceInfo(
            title: "Total",
            amount:
                "${total >= 0 ? "+" : "-"} ₭ ${total.abs().toStringAsFixed(0)}",
            color: total >= 0 ? Colors.blue : Colors.red,
          ),
        ),
      ],
    );
  }
}

// ignore: camel_case_types
class my_buildFinanceInfo extends StatelessWidget {
  const my_buildFinanceInfo({
    super.key,
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
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
