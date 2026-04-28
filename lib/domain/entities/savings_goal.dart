class SavingsGoalEntity {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final String icon;

  const SavingsGoalEntity({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    required this.icon,
  });

  double get progress => currentAmount / targetAmount;
  int get daysRemaining => deadline.difference(DateTime.now()).inDays;
}
