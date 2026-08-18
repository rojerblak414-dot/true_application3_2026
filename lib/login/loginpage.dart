import 'package:flutter/material.dart';
import 'package:true_application_3/component/inputfield_loginpage.dart';
import 'package:true_application_3/login/register.dart';
import 'package:true_application_3/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please enter email and password');
      return;
    }

    setState(() => isLoading = true);
    try {
      final user = await AuthService.login(email, password);
      if (!mounted) return;

      if (user == null) {
        _showMessage('Email or password is incorrect');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (_) {
      if (mounted) _showMessage('Could not connect to the API');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    emailController.text = "dee@gmail.com";
    passwordController.text = "a123456";
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.asset(
                      'assets/images/in.png',
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    " Expences Tracker",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Text(
                    'ບັນທືກລານຮັບ ລາຍຈ້າຍ',
                    style: TextStyle(color: Colors.orange, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'WELCOME',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  inputfield_loginpage(
                    controller: emailController,
                    icon: Icons.email,
                    hint: 'Email',
                    obscure: false,
                  ),
                  const SizedBox(height: 15),
                  inputfield_loginpage(
                    controller: passwordController,
                    icon: Icons.lock,
                    hint: 'ລະຫັດຜ່ານ',
                    obscure: true,
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: 500,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Login', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('ຍັງບໍ່ມີບັນຊີ?'),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      );
                    },
                    child: const Text(
                      'ສະຫມັກສະມາຊິກ',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
