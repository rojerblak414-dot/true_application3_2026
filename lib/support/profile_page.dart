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
    // ใช้ Future เพื่อสั่งให้ Firebase รีโหลดข้อมูลล่าสุดก่อนแสดงผล
    return FutureBuilder(
      future: FirebaseAuth.instance.currentUser?.reload(),
      builder: (context, snapshot) {
        final user =
            FirebaseAuth.instance.currentUser; // ดึงข้อมูล User ปัจจุบัน

        return Scaffold(
          appBar: AppBar(title: const Text("Profile"), centerTitle: true),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // รูปโปรไฟล์ (ถ้ามี photoURL ให้ใช้ ถ้าไม่มีใช้รูปเดิม)
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : const AssetImage("assets/images/oak.jpg")
                            as ImageProvider,
                ),

                const SizedBox(height: 30),

                // แสดงชื่อ (จะดึงมาจากชื่อที่บันทึกตอนสมัคร)
                myinfo_box(
                  icon: Icons.person,
                  title: "Name",
                  value: user?.displayName ?? "No Name",
                ),

                const SizedBox(height: 20),

                // แสดง Email
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
                // ... ส่วนที่เหลือของโค้ดคุณ (Add Expense/Income) ...
              ],
            ),
          ),
        );
      },
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:true_application_3/support/Add_expense_page.dart';
// import 'Add_income_page.dart';

// class ProfilePage extends StatefulWidget {
//   // เปลี่ยนเป็น StatefulWidget เพื่อให้หน้าจอ Refresh ได้
//   const ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   // ฟังก์ชันอัปเดตชื่อ
//   Future<void> _updateUserName(String newName) async {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       await user.updateDisplayName(newName);
//       await user.reload();
//       setState(() {}); // สั่งให้หน้าจอวาดใหม่เพื่อแสดงชื่อที่เพิ่งเปลี่ยน
//     }
//   }

//   // ฟังก์ชันแสดงหน้าต่างกรอกชื่อ
//   void _showEditDialog() {
//     final TextEditingController _controller = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("แก้ไขชื่อของคุณ"),
//         content: TextField(
//           controller: _controller,
//           decoration: const InputDecoration(hintText: "กรอกชื่อที่นี่"),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("ยกเลิก"),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               if (_controller.text.isNotEmpty) {
//                 await _updateUserName(_controller.text);
//                 Navigator.pop(context);
//               }
//             },
//             child: const Text("บันทึก"),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;

//     return Scaffold(
//       appBar: AppBar(title: const Text("Profile"), centerTitle: true),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             const SizedBox(height: 20),

//             // รูปโปรไฟล์
//             CircleAvatar(
//               radius: 50,
//               backgroundImage: (user?.photoURL != null)
//                   ? NetworkImage(user!.photoURL!)
//                   : const AssetImage("assets/images/oak.jpg") as ImageProvider,
//             ),

//             const SizedBox(height: 30),

//             // Name Box (เพิ่ม GestureDetector เพื่อให้กดแล้วแก้ไขได้)
//             GestureDetector(
//               onTap: _showEditDialog,
//               child: _infoBox(
//                 icon: Icons.person,
//                 title: "Name (แตะเพื่อแก้ไข)",
//                 value: user?.displayName ?? "No Name", //
//               ),
//             ),

//             const SizedBox(height: 20),

//             // Email Box
//             _infoBox(
//               icon: Icons.email,
//               title: "Email",
//               value: user?.email ?? "No Email", //
//             ),

//             const SizedBox(height: 30),

//             _menuButton(
//               icon: Icons.bar_chart,
//               text: "Add Expense",
//               onTap: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const AddExpensePage()),
//               ),
//             ),

//             const SizedBox(height: 20),

//             _menuButton(
//               icon: Icons.attach_money,
//               text: "Add Income",
//               onTap: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const AddIncomePage()),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _infoBox({
//     required IconData icon,
//     required String title,
//     required String value,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: Colors.orange,
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: Colors.white),
//           const SizedBox(width: 15),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Text(
//                 value,
//                 style: const TextStyle(color: Colors.white, fontSize: 16),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _menuButton({
//     required IconData icon,
//     required String text,
//     required VoidCallback onTap,
//   }) {
//     return SizedBox(
//       width: double.infinity,
//       height: 55,
//       child: ElevatedButton.icon(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.orange,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15),
//           ),
//         ),
//         icon: Icon(icon, color: Colors.white),
//         label: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               text,
//               style: const TextStyle(fontSize: 18, color: Colors.white),
//             ),
//             const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
//           ],
//         ),
//         onPressed: onTap,
//       ),
//     );
//   }
// }
