import 'package:flutter/material.dart';

// ignore: camel_case_types
class inputfield_loginpage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  inputfield_loginpage({
    super.key,
    required this.controller,
    required this.icon,
    required this.hint,
    required this.obscure,
  });

  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF9CB7E5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.black),
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
