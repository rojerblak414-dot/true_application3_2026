// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';

// class Register extends StatefulWidget {
//   const Register({super.key});

//   @override
//   State<Register> createState() => _RegisterState();
// }

// class _RegisterState extends State<Register> {
//   final TextEditingController emailcontroller = TextEditingController();
//   final TextEditingController passwordcontroller = TextEditingController();
//   final TextEditingController confirmcontroller = TextEditingController();
//   bool isLoading = false;
//   Future<void> register() async {
//     if (passwordcontroller.text != confirmcontroller.text) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Password  ບໍຄືກັນ")));
//       return;
//     }
//     setState(()=> isLoading=true);
//    try{
//     await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailcontroller.text.trim(),
//      password: passwordcontroller.text.trim(),
//      );
//      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ສະມັກສະມາຊິກສຳເລັດ")),
//      );
//      Navigator.pop(context);
//    }
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class RegisterPage extends StatefulWidget {
//   const RegisterPage({super.key});

//   @override
//   State<RegisterPage> createState() => _RegisterPageState();
// }

// class _RegisterPageState extends State<RegisterPage> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   bool isLoading = false;

//   Future<void> register() async {
//     if (passwordController.text != passwordController.text) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Password ไม่ตรงกัน")));
//       return;
//     }

//     setState(() => isLoading = true);

//     try {
//       await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: emailController.text.trim(),
//         password: passwordController.text.trim(),
//       );

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("สมัครสมาชิกสำเร็จ")));

//       Navigator.pop(context);
//     } on FirebaseAuthException catch (e) {
//       String message = "เกิดข้อผิดพลาด";

//       if (e.code == 'email-already-in-use') {
//         message = "อีเมลนี้ถูกใช้งานแล้ว";
//       } else if (e.code == 'weak-password') {
//         message = "รหัสผ่านต้องมากกว่า 6 ตัวอักษร";
//       } else if (e.code == 'invalid-email') {
//         message = "รูปแบบอีเมลไม่ถูกต้อง";
//       }

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(message)));
//     }

//     setState(() => isLoading = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(25),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.arrow_back),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 20),

//               const Text(
//                 "Register  For Free",
//                 style: TextStyle(
//                   fontSize: 22,
//                   color: Colors.blue,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),

//               const SizedBox(height: 40),

//               _inputField("Name", emailController, false),
//               _inputField("Email Address", passwordController, true),
//               _inputField("Password", passwordController, true),

//               const SizedBox(height: 40),

//               SizedBox(
//                 width: double.infinity,
//                 height: 55,
//                 child: ElevatedButton(
//                   onPressed: isLoading ? null : register,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blueAccent,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                   ),
//                   child: isLoading
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : const Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text("Register", style: TextStyle(fontSize: 18)),
//                             SizedBox(width: 10),
//                             Icon(Icons.arrow_forward),
//                           ],
//                         ),
//                 ),
//               ),

//               const SizedBox(height: 40),

//               const Text(
//                 "Already have an account ?",
//                 style: TextStyle(fontSize: 16),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _inputField(
//     String label,
//     TextEditingController controller,
//     bool obscure,
//   ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label),
//         const SizedBox(height: 8),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           decoration: BoxDecoration(
//             color: Colors.grey[300],
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: TextField(
//             controller: controller,
//             obscureText: obscure,
//             decoration: const InputDecoration(border: InputBorder.none),
//           ),
//         ),
//       ],
//     );
//   }
// }
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
    // ✅ เช็ครหัสผ่านกับ confirm password
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
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                "Register For Free",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 40),

              // ✅ แก้ controller ถูกต้องแล้ว
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
                            Text("Register", style: TextStyle(fontSize: 18)),
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
