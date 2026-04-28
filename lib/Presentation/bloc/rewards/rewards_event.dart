import 'package:equatable/equatable.dart';

abstract class RewardsEvent extends Equatable {
  const RewardsEvent();
  @override
  List<Object?> get props => [];
}

class LoadRewardsEvent extends RewardsEvent {}

class RedeemRewardEvent extends RewardsEvent {
  final String rewardId;
  const RedeemRewardEvent(this.rewardId);
  @override
  List<Object?> get props => [rewardId];
}
