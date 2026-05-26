import 'package:cloud_firestore/cloud_firestore.dart';

class Model {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String type;
  final String userId;

  Model({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
    required this.userId,
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

class TransactionModel {
  final String id;
  final double amount;
  final String category;
  final DateTime createdAt;
  final String userId;
  final bool isExpense;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.createdAt,
    required this.userId,
    required this.isExpense,
  });

  // ฟังก์ชันแปลงข้อมูลจาก DocumentSnapshot ของ Firebase มาเป็น Object ในแอป
  factory TransactionModel.fromFirestore(
    DocumentSnapshot doc,
    bool isExpenseValue,
  ) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Timestamp ts = data['createdAt'] ?? Timestamp.now();

    return TransactionModel(
      id: doc.id,
      amount: (data['amount'] ?? 0).toDouble(),
      category: isExpenseValue ? (data['category'] ?? 'Food') : 'Income',
      createdAt: ts.toDate(),
      userId: data['userId'] ?? '',
      isExpense: isExpenseValue,
    );
  }
}
// class TransactionModel {
//   final String id;
//   final String userId;
//   final String category;
//   final double amount;
//   final DateTime createdAt;
//   final bool isExpense;

//   TransactionModel({
//     required this.id,
//     required this.userId,
//     required this.category,
//     required this.amount,
//     required this.createdAt,
//     required this.isExpense,
//   });

//   // ✅ จาก JSON Server (เพิ่มใหม่)
//   factory TransactionModel.fromJson(Map<String, dynamic> json, bool isExpense) {
//     return TransactionModel(
//       id: json['id'].toString(),
//       userId: json['userId'] ?? '',
//       category: json['category'] ?? '',
//       amount: (json['amount'] ?? 0).toDouble(),
//       createdAt: DateTime.parse(json['createdAt']),
//       isExpense: isExpense,
//     );
//   }

//   // ✅ แปลงกลับเป็น JSON (สำหรับ POST/PUT)
//   Map<String, dynamic> toJson() {
//     return {
//       'userId': userId,
//       'category': category,
//       'amount': amount,
//       'createdAt': createdAt.toIso8601String(),
//     };
//   }
// }
