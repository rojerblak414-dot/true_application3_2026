import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:true_application_3/component/inputfield_loginpage.dart';
import 'package:true_application_3/login/register.dart';

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
    setState(() => isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      // ຖ້າ login ສຳເລັດໄຫ້ໄປຫ້ນາ → Home
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      String message = "ເກີດຂໍ້ຜິດພາດ";
      if (e.code == 'user-not-found') {
        message = "ບໍ່ພົບອີເມວນີໃນລະບົບ";
      } else if (e.code == 'wrong-password') {
        message = "ລະຫັດຜານບໍ່ຖືກຕ້ອງ";
      } else if (e.code == 'invalid-email') {
        message = "ຮູບແບບອີເມວ ບໍ່ຖືກຕ້ອງ";
      } else {
        message = "ອີເມວຫຼືລະຫັດບໍ່ຖືກຕ້ອງ";
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
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
                    borderRadius: BorderRadiusGeometry.circular(60),
                    child: Image.asset(
                      "assets/images/in.png",
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Let's start tracking",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Text(
                    "income & expenses",
                    style: TextStyle(color: Colors.orange, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "WELCOME",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  inputfield_loginpage(
                    controller: emailController,
                    icon: Icons.email,
                    hint: "Email",
                    obscure: false,
                  ),
                  const SizedBox(height: 15),
                  // Password
                  inputfield_loginpage(
                    controller: passwordController,
                    icon: Icons.lock,
                    hint: "Password",
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
                          : const Text(
                              "ເຂົ້າສູ່ລະບົບ",
                              style: TextStyle(fontSize: 20),
                            ),
                    ),
                  ),
                  SizedBox(height: 20),

                  Text(
                    "ທ່ານຍັງບໍ່ມີບັນຊີ ?",
                    style: TextStyle(color: Colors.black),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      );
                    },
                    child: Text(
                      "ລົງທະບຽນຜູ້ໃຊ້ງານໃໝ່",
                      style: TextStyle(color: Colors.red, fontSize: 16.0),
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
