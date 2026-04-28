import '../../domain/entities/transaction.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.amount,
    required super.date,
    required super.description,
    required super.isCredit,
    super.status = 'Completed',
    super.notes,
    super.category = 'General',
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      description: json['description'],
      isCredit: json['isCredit'],
      status: json['status'] ?? 'Completed',
      notes: json['notes'],
      category: json['category'] ?? 'General',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
      'isCredit': isCredit,
      'status': status,
      'notes': notes,
      'category': category,
    };
  }
}
