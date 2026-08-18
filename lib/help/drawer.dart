import 'package:flutter/material.dart';
import 'package:true_application_3/services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthService.logout();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<Map<String, String>>(
        future: AuthService.getCurrentUserInfo(),
        builder: (context, snapshot) {
          final info = snapshot.data ?? const {
            'name': 'No Name',
            'email': 'No Email',
          };

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(info['name'] ?? 'No Name'),
                accountEmail: Text(info['email'] ?? 'No Email'),
                currentAccountPicture: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/home');
                },
              ),
              ListTile(
                leading: const Icon(Icons.shopping_bag),
                title: const Text('Add Expense'),
                onTap: () => Navigator.popAndPushNamed(
                  context,
                  '/AddExpensePage',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text('Add Income'),
                onTap: () => Navigator.popAndPushNamed(
                  context,
                  '/AddIncomePage',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () => _logout(context),
              ),
            ],
          );
        },
      ),
    );
  }
}
