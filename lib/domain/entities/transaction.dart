class TransactionEntity {
  final String id;
  final double amount;
  final DateTime date;
  final String description;
  final bool isCredit;

  const TransactionEntity({
    required this.id,
    required this.amount,
    required this.date,
    required this.description,
    required this.isCredit,
  });
}
