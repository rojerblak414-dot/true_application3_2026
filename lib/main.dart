import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:true_application_3/firebase_options.dart';
import 'package:true_application_3/login/loginpage.dart';
import 'package:true_application_3/support/Add_expense_page.dart';
import 'package:true_application_3/support/Add_income_page.dart';
import 'package:true_application_3/support/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/AddExpensePage': (context) => AddExpensePage(),
        '/AddIncomePage': (context) => AddIncomePage(),
      },
    );
  }
}
