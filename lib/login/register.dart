import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:true_application_3/component/inputfileld_register.dart';

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
    // ✅ ກວດລະຫັດຜ່ານ confirm password
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Password ไม่ตรงกัน")));
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("ສະມັກສະມາຊິກສຳເລັດ")));

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = "ເກີດຂໍ້ຜິດພາດ";

      if (e.code == 'email-already-in-use') {
        message = "ອີເມວນີຖືກໃຊ້ງານແລ້ວ";
      } else if (e.code == 'weak-password') {
        message = "ລະຫັດຕ້ອງຫຼາຍກ່ວາ 6 ຕົວອັກສອນ";
      } else if (e.code == 'invalid-email') {
        message = "ຮູບແບບອີເມວ ບໍ່ຖືກຕ້ອງ";
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
              ClipRRect(
                borderRadius: BorderRadiusGeometry.circular(60),
                child: Image.asset(
                  "assets/images/in.png",
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "ລົງທະບຽນ",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 40),

              // ✅ ແກ້ controller ຖືກຕ້ອງແລ້ວ
              inputfileld_register(
                label: "Name",
                controller: nameController,
                obscure: false,
              ),

              const SizedBox(height: 15),

              inputfileld_register(
                label: "Email Address",
                controller: emailController,
                obscure: false,
              ),
              const SizedBox(height: 15),

              inputfileld_register(
                label: "Password",
                controller: passwordController,
                obscure: true,
              ),
              const SizedBox(height: 15),

              inputfileld_register(
                label: "Confirm Password",
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
                            Text("ສະໝັກ", style: TextStyle(fontSize: 18)),
                            SizedBox(width: 10),
                            Icon(Icons.arrow_forward),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                "Already have an account?",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
