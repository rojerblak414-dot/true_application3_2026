import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: camel_case_types
class my_builheader extends StatelessWidget {
  const my_builheader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome back",
          style: TextStyle(
            fontSize: 20,
            color: Color.fromARGB(255, 19, 19, 19),
          ),
        ),
        Text(
          "Manage your expenses",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
