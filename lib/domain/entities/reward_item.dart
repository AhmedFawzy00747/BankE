enum RewardCategory { shopping, travel, dining, cashback }

class RewardItemEntity {
  final String id;
  final String title;
  final String description;
  final int pointsRequired;
  final String imageUrl;
  final RewardCategory category;

  const RewardItemEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsRequired,
    required this.imageUrl,
    required this.category,
  });
}

class RewardRedemption {
  final String id;
  final String rewardTitle;
  final DateTime date;
  final int pointsSpent;

  const RewardRedemption({
    required this.id,
    required this.rewardTitle,
    required this.date,
    required this.pointsSpent,
  });
}
