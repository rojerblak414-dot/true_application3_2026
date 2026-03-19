// // // ignore: unused_field
// // class Model {
// //   final String email;
// //   final String password;

// //   Model({

// //   })
// // }
// // import 'package:cloud_firestore/cloud_firestore.dart';

// // class EmployeeModel {
// //   final String id;
// //   final String name;
// //   final String tel;
// //   final String title;
// //   final String imageUrl; // เพิ่มตัวนี้

// //   EmployeeModel({
// //     required this.id,
// //     required this.name,
// //     required this.tel,
// //     required this.title,
// //     required this.imageUrl,
// //   });

// //   factory EmployeeModel.fromFirestore(DocumentSnapshot doc) {
// //     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
// //     return EmployeeModel(
// //       id: doc.id,
// //       name: data['name'] ?? '',
// //       tel: data['tel'] ?? '',
// //       title: data['title'] ?? '',
// //       imageUrl: data['imageUrl'] ?? '', // ดึงค่าจาก Firestore
// //     );
// //   }

// //   // ฟังก์ชันช่วยสร้าง Model เปล่าสำหรับหน้า Add
// //   factory EmployeeModel.empty() {
// //     return EmployeeModel(id: '', name: '', tel: '', title: '', imageUrl: '');
// //   }
// // }
// import 'package:cloud_firestore/cloud_firestore.dart';

// // --- 1. Model สำหรับข้อมูล User ---
// class UserModel {
//   final String uid;
//   final String? email;

//   UserModel({required this.uid, this.email});

//   // ดึงข้อมูลจาก Firebase Auth มาใส่ใน Model
//   factory UserModel.fromFirebase(dynamic user) {
//     return UserModel(uid: user.uid, email: user.email);
//   }
// }

// // --- 2. Model สำหรับข้อมูล รายรับ-รายจ่าย ---
// class TransactionModel {
//   final String id;
//   final double amount;
//   final String category;
//   final String piechart;
//   final DateTime date;
//   final String type; // "income" หรือ "expense"

//   TransactionModel({
//     required this.id,
//     required this.amount,
//     required this.category,
//     required this.piechart,
//     required this.date,
//     required this.type,
//   });

//   // แปลงข้อมูลจาก Firestore QuerySnapshot เป็น List ของ Model
//   factory TransactionModel.fromFirestore(DocumentSnapshot doc, String type) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

//     return TransactionModel(
//       id: doc.id,
//       amount: (data['amount'] ?? 0).toDouble(),
//       category: data['category'] ?? (type == 'income' ? 'Salary' : 'General'),
//       // ตรวจสอบฟิลด์วันที่ (ในโค้ดคุณใช้ createdAt)
//       date: (data['createdAt'] as Timestamp).toDate(),
//       type: type,
//       piechart: 'piechart',
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';

class Model {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String type;
  final String userId; // <--- เพิ่มตัวนี้

  Model({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
    required this.userId, // <--- เพิ่มตัวนี้
  });

  factory Model.fromFirestore(DocumentSnapshot doc, String type) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Model(
      id: doc.id,
      amount: (data['amount'] ?? 0).toDouble(),
      category: data['category'] ?? (type == 'income' ? 'Salary' : 'General'),
      date: (data['createdAt'] as Timestamp).toDate(),
      type: type,
      userId:
          data['userId'] ??
          "", // <--- ดึงค่า userId จาก Firestore มาใส่ใน Model
    );
  }
}
