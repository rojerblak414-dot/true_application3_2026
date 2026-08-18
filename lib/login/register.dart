import 'package:flutter/material.dart';
import 'package:true_application_3/component/inputfileld_register.dart';
import 'package:true_application_3/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showMessage('Please fill in all fields');
      return;
    }
    if (!email.contains('@')) {
      _showMessage('Email format is not valid');
      return;
    }
    if (password.length < 6) {
      _showMessage('Password must be at least 6 characters');
      return;
    }
    if (password != confirmPassword) {
      _showMessage('Passwords do not match');
      return;
    }

    setState(() => isLoading = true);
    try {
      await AuthService.register(name, email, password);
      if (!mounted) return;
      _showMessage('Register success');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().contains('email-already-in-use')
          ? 'Email is already in use'
          : 'Register failed';
      _showMessage(message);
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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: Image.asset(
                  'assets/images/in.png',
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'ສະໝັກສະມາຊິກ',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),
              inputfileld_register(
                label: 'ຊື່ແລະນາມສະກຸນ',
                controller: nameController,
                obscure: false,
              ),
              const SizedBox(height: 15),
              inputfileld_register(
                label: 'Email ',
                controller: emailController,
                obscure: false,
              ),
              const SizedBox(height: 15),
              inputfileld_register(
                label: 'ລະຫັດຜານ',
                controller: passwordController,
                obscure: true,
              ),
              const SizedBox(height: 15),
              inputfileld_register(
                label: 'ຢືນຢັນລະຫັດຜານ',
                controller: confirmPasswordController,
                obscure: true,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Register', style: TextStyle(fontSize: 18)),
                            SizedBox(width: 10),
                            Icon(Icons.arrow_forward),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 40),
              const Text('ມີບັນຊີຢູ່ແລ້ວ ?', style: TextStyle(fontSize: 16)),
              Text("ເຂົ້າສູລະບົບ !", style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
