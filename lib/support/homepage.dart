import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:true_application_3/component/dashboard_empty_state.dart';
import 'package:true_application_3/component/expense_chart_card.dart';
import 'package:true_application_3/component/finance_summary_row.dart';
import 'package:true_application_3/component/transaction_tile.dart';
import 'package:true_application_3/component/my_builheader.dart';
import 'package:true_application_3/help/drawer.dart';
import 'package:true_application_3/models/expense_model.dart';
import 'package:true_application_3/models/income_model.dart';
import 'package:true_application_3/models/transaction_model.dart';
import 'package:true_application_3/services/auth_service.dart';
import 'package:true_application_3/services/expense_service.dart';
import 'package:true_application_3/services/income_service.dart';
import 'package:true_application_3/support/Add_expense_page.dart';
import 'package:true_application_3/support/Add_income_page.dart';
import 'package:true_application_3/support/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NumberFormat _money = NumberFormat.decimalPattern();
  late Future<_DashboardData> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboard();
  }

  Future<_DashboardData> _loadDashboard() async {
    final userId = await AuthService.getCurrentUserId();
    if (userId == null) {
      throw Exception('not-authenticated');
    }

    final results = await Future.wait([
      ExpenseService.getByUser(userId),
      IncomeService.getByUser(userId),
    ]);

    return _DashboardData(
      expenses: results[0] as List<ExpenseModel>,
      incomes: results[1] as List<IncomeModel>,
    );
  }

  void _refresh() {
    setState(() {
      _dashboardFuture = _loadDashboard();
    });
  }

  Future<void> _openAddExpense() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddExpensePage()),
    );
    _refresh();
  }

  Future<void> _openAddIncome() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddIncomePage()),
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const my_builheader(),
                const SizedBox(height: 25),
                FutureBuilder<_DashboardData>(
                  future: _dashboardFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      if (snapshot.error.toString().contains(
                        'not-authenticated',
                      )) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/',
                            (route) => false,
                          );
                        });
                      }
                      return DashboardEmptyState(
                        icon: Icons.wifi_off,
                        message: 'Could not load data. Check the API server.',
                        action: _refresh,
                      );
                    }

                    final data = snapshot.data!;
                    return _buildDashboard(data);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(_DashboardData data) {
    final totalExpense = data.totalExpense;
    final totalIncome = data.totalIncome;
    final categoryMap = data.categoryMap;
    final transactions = data.transactions.take(5).toList();

    return Column(
      children: [
        ExpenseChartCard(total: totalExpense, categories: categoryMap),
        const SizedBox(height: 25),
        FinanceSummaryRow(
          income: totalIncome,
          expense: totalExpense,
          onIncomeTap: _openAddIncome,
          onExpenseTap: _openAddExpense,
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('History', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 15),
        if (transactions.isEmpty)
          DashboardEmptyState(
            icon: Icons.receipt_long,
            message: 'No transactions yet',
            action: null,
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              return TransactionTile(transaction: transactions[index]);
            },
          ),
      ],
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
          ).then((_) => _refresh()),
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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Expenses',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '₭ ${_money.format(total)}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 160, // fix width แทน height
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 35,
                      sections: _buildPieChartSections(total, categories),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: categories.entries
                        .map(
                          (e) => _buildCategoryItem(
                            e.key,
                            '₭ ${_money.format(e.value)}',
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
    if (total <= 0) {
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
    // สีตายตัวสำหรับ category เดิม
    switch (category) {
      case 'Car':
        return Colors.orange;
      case 'Internet':
        return Colors.red;
      case 'Food':
        return Colors.blue;
    }

    // category ที่เพิ่มใหม่ → สลับสีจาก list
    const extraColors = [
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
      Colors.deepOrange,
      Colors.lime,
    ];

    final index = category.hashCode.abs() % extraColors.length;
    return extraColors[index];
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
          Expanded(
            child: Column(
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
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardData {
  _DashboardData({required this.expenses, required this.incomes});

  final List<ExpenseModel> expenses;
  final List<IncomeModel> incomes;

  double get totalExpense =>
      expenses.fold(0, (total, expense) => total + expense.amount);

  double get totalIncome =>
      incomes.fold(0, (total, income) => total + income.amount);

  Map<String, double> get categoryMap {
    final map = <String, double>{'Car': 0, 'Internet': 0, 'Food': 0};
    for (final expense in expenses) {
      map[expense.category] = (map[expense.category] ?? 0) + expense.amount;
    }
    return map;
  }

  List<TransactionModel> get transactions {
    final all = <TransactionModel>[
      ...expenses.map(
        (expense) => TransactionModel(
          id: expense.id,
          amount: expense.amount,
          category: expense.category,
          createdAt: expense.createdAt,
          isExpense: true,
        ),
      ),
      ...incomes.map(
        (income) => TransactionModel(
          id: income.id,
          amount: income.amount,
          category: 'Income',
          createdAt: income.createdAt,
          isExpense: false,
        ),
      ),
    ];
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all;
  }
}

class _FinanceSummaryRow extends StatelessWidget {
  const _FinanceSummaryRow({
    required this.income,
    required this.expense,
    required this.onIncomeTap,
    required this.onExpenseTap,
    required this.money,
  });

  final double income;
  final double expense;
  final VoidCallback onIncomeTap;
  final VoidCallback onExpenseTap;
  final NumberFormat money;

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
              amount: '+ ₭ ${money.format(income)}',
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
              amount: '- ₭ ${money.format(expense)}',
              color: Colors.red,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _FinanceInfo(
            title: 'Total',
            amount: '${total >= 0 ? '+' : '-'} ₭ ${money.format(total.abs())}',
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

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.tx, required this.money});

  final TransactionModel tx;
  final NumberFormat money;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('d/M/yyyy').format(tx.createdAt);
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
                  tx.category,
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
            '${tx.isExpense ? '-' : '+'} ₭ ${money.format(tx.amount)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: tx.isExpense ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message, this.action});

  final IconData icon;
  final String message;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(icon, size: 42, color: Colors.grey),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(color: Colors.grey)),
            if (action != null) ...[
              const SizedBox(height: 12),
              TextButton(onPressed: action, child: const Text('Try again')),
            ],
          ],
        ),
      ),
    );
  }
}
