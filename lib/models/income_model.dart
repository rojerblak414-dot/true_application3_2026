class IncomeModel {
  final String id;
  final String userId;
  final double amount;
  final DateTime createdAt;

  const IncomeModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.createdAt,
  });

  factory IncomeModel.fromJson(Map<String, dynamic> json) {
    return IncomeModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      amount: (json['amount'] as num? ?? 0).toDouble(),
      createdAt:
          DateTime.tryParse(
            (json['createdAt'] ?? json['date'])?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'amount': amount,
      'createdAt': createdAt.toIso8601String().substring(0, 10),
      'date': createdAt.toIso8601String(),
    };
  }
}
