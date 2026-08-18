class ExpenseModel {
  final String id;
  final String userId;
  final double amount;
  final String category;
  final DateTime createdAt;

  const ExpenseModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.category,
    required this.createdAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      amount: (json['amount'] as num? ?? 0).toDouble(),
      category: json['category']?.toString() ?? 'Other',
      // ອ່ານຄ່າຈາກ createdAt ໂດຍກົງ
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'userId': userId,
      'amount': amount,
      'category': category,
      'createdAt': createdAt
          .toIso8601String(), // ເກັບຄ່າແບບເຕັມທີ່ມີທັງ ວັນທີ ແລະ ເວລາ
    };

    // ຖ້າມີ id ໃຫ້ໃສ່ id ໄປນຳ (ໃຊ້ສຳລັບການອັບເດດ)
    if (id.isNotEmpty) {
      map['id'] = id;
    }
    return map;
  }
}
