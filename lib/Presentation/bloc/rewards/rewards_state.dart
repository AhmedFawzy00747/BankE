import 'package:equatable/equatable.dart';
import '../../../domain/entities/reward_item.dart';

abstract class RewardsState extends Equatable {
  const RewardsState();
  @override
  List<Object?> get props => [];
}

class RewardsInitial extends RewardsState {}

class RewardsLoading extends RewardsState {}

class RewardsLoaded extends RewardsState {
  final int currentPoints;
  final String tier; // Silver, Gold, Platinum
  final double progressToNextTier; // 0.0 to 1.0
  final List<RewardItemEntity> catalog;
  final List<RewardRedemption> redemptions;

  const RewardsLoaded({
    required this.currentPoints,
    required this.tier,
    required this.progressToNextTier,
    required this.catalog,
    required this.redemptions,
  });

  @override
  List<Object?> get props => [currentPoints, tier, progressToNextTier, catalog, redemptions];
}

class RewardsError extends RewardsState {
  final String message;
  const RewardsError(this.message);
  @override
  List<Object?> get props => [message];
}

class RedeemSuccess extends RewardsLoaded {
  final String message;
  const RedeemSuccess(this.message, {
    required super.currentPoints,
    required super.tier,
    required super.progressToNextTier,
    required super.catalog,
    required super.redemptions,
  });

  @override
  List<Object?> get props => [...super.props, message];
}

class RedeemFailure extends RewardsLoaded {
  final String message;
  const RedeemFailure(this.message, {
    required super.currentPoints,
    required super.tier,
    required super.progressToNextTier,
    required super.catalog,
    required super.redemptions,
  });

  @override
  List<Object?> get props => [...super.props, message];
}
