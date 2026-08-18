import 'package:flutter/material.dart';
import 'package:true_application_3/login/loginpage.dart';
import 'package:true_application_3/services/auth_service.dart';
import 'package:true_application_3/support/Add_expense_page.dart';
import 'package:true_application_3/support/Add_income_page.dart';
import 'package:true_application_3/support/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final userId = await AuthService.getCurrentUserId();
  runApp(MyApp(initialRoute: userId == null ? '/' : '/home'));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.initialRoute = '/'});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: initialRoute,
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/AddExpensePage': (context) => const AddExpensePage(),
        '/AddIncomePage': (context) => const AddIncomePage(),
      },
    );
  }
}
