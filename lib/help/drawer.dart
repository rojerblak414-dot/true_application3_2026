import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.all(8.0),
        children: [
          UserAccountsDrawerHeader(
            accountName: Text("seub KeoMaNeeSouk"),
            accountEmail: Text("rojerblak414@gmail.com"),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage("assets/images/oak.jpg"),
            ),
          ),

          ListTile(
            leading: Icon(Icons.home),
            title: Text("home"),
            onTap: () => Navigator.pushNamed(context, '/'),
          ),
          ListTile(
            leading: Icon(Icons.shopping_bag),
            title: Text("AddExpensePage"),
            onTap: () => Navigator.popAndPushNamed(context, '/AddExpensePage'),
          ),
          ListTile(
            leading: Icon(Icons.shopping_bag),
            title: Text("AddIncomePage "),
            onTap: () => Navigator.popAndPushNamed(context, '/AddIncomePage'),
          ),
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ), // ไอคอน Logout สีแดง
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              // 1. ยืนยันการออกจากระบบจาก Firebase
              await FirebaseAuth.instance.signOut(); //

              // 2. ปิดหน้า Drawer
              if (context.mounted) Navigator.pop(context);

              // 3. กลับไปที่หน้า Login และลบประวัติการเข้าหน้าเดิมทั้งหมด
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
    );
  }
}
