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
