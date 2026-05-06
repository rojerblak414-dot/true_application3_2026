import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:true_application_3/support/Add_expense_page.dart';
import 'Add_income_page.dart';
import 'package:true_application_3/component/myinfo_box.dart';
import 'package:true_application_3/component/mymenu_button.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    //  ໃຊ້ Future ເພື່ອສັງໄຫ້ Firebase ລີໂລດຂໍ້ມູນລາສຸດກອນສະແດງຜົນ
    return FutureBuilder(
      future: FirebaseAuth.instance.currentUser?.reload(),
      builder: (context, snapshot) {
        final user = FirebaseAuth.instance.currentUser; // ດຶ່ງ User ປັດຈຸບັນ

        return Scaffold(
          appBar: AppBar(title: const Text("Profile"), centerTitle: true),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                CircleAvatar(radius: 50, child: Icon(Icons.handshake)),

                const SizedBox(height: 30),

                // ສະແດງຊື່ ຈະດືງມາຈາກຊື່ທິບັນທືກຕອນສະໝັກ
                myinfo_box(
                  icon: Icons.person,
                  title: "Name",
                  value: user?.displayName ?? "No Name",
                ),

                const SizedBox(height: 20),

                //ສະແດງ Email
                myinfo_box(
                  icon: Icons.email,
                  title: "Email",
                  value: user?.email ?? "No Email",
                ),
                const SizedBox(height: 30),

                mymenu_button(
                  icon: Icons.bar_chart,
                  text: "Add Expense",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddExpensePage()),
                  ),
                ),

                const SizedBox(height: 20),

                mymenu_button(
                  icon: Icons.attach_money,
                  text: "Add Income",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddIncomePage()),
                  ),
                ),
                SizedBox(height: 20),
                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: Colors.red,
                  ), // ไอคอน Logout สีแดง
                  title: const Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () async {
                    // 1. ຍືນຍັນການອອກຈາກລະບົບ Firebase
                    await FirebaseAuth.instance.signOut(); //

                    // 2. ປິດໜ້າ Drawer
                    if (context.mounted) Navigator.pop(context);

                    // 3. ກັບໄປໜ້າ  Login ແລະລົບປະຫວັດເກົ່າທັງໝົດ
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/',
                        (route) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
