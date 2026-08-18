import 'package:flutter/material.dart';
import 'package:true_application_3/component/myinfo_box.dart';
import 'package:true_application_3/component/mymenu_button.dart';
import 'package:true_application_3/services/auth_service.dart';
import 'package:true_application_3/support/Add_expense_page.dart';
import 'package:true_application_3/support/Add_income_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthService.logout();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: AuthService.getCurrentUserInfo(),
      builder: (context, snapshot) {
        final info =
            snapshot.data ?? const {'name': 'No Name', 'email': 'No Email'};

        return Scaffold(
          appBar: AppBar(title: const Text('Profile'), centerTitle: true),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const CircleAvatar(radius: 50, child: Icon(Icons.person)),
                const SizedBox(height: 30),
                myinfo_box(
                  icon: Icons.person,
                  title: 'Name',
                  value: info['name'] ?? 'No Name',
                ),
                const SizedBox(height: 20),
                myinfo_box(
                  icon: Icons.email,
                  title: 'Email',
                  value: info['email'] ?? 'No Email',
                ),
                const SizedBox(height: 30),
                mymenu_button(
                  icon: Icons.bar_chart,
                  text: 'Add Expense',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddExpensePage()),
                  ),
                ),
                const SizedBox(height: 20),
                mymenu_button(
                  icon: Icons.attach_money,
                  text: 'Add Income',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddIncomePage()),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'ອອກຈາກລະບົບ',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => _logout(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
