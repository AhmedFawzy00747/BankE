import 'package:flutter_bloc/flutter_bloc.dart';
import 'rewards_event.dart';
import 'rewards_state.dart';
import '../../../domain/entities/reward_item.dart';

class RewardsBloc extends Bloc<RewardsEvent, RewardsState> {
  RewardsBloc() : super(RewardsInitial()) {
    on<LoadRewardsEvent>(_onLoadRewards);
    on<RedeemRewardEvent>(_onRedeemReward);
  }

  void _onLoadRewards(LoadRewardsEvent event, Emitter<RewardsState> emit) {
    emit(RewardsLoading());
    
    final catalog = [
      const RewardItemEntity(
        id: 'r1',
        title: '\$50 Amazon Gift Card',
        description: 'Redeem for any item on Amazon.com',
        pointsRequired: 5000,
        imageUrl: 'https://img.icons8.com/color/96/amazon.png',
        category: RewardCategory.shopping,
      ),
      const RewardItemEntity(
        id: 'r2',
        title: '\$20 Starbucks Voucher',
        description: 'Enjoy your favorite coffee on us',
        pointsRequired: 2000,
        imageUrl: 'https://img.icons8.com/color/96/starbucks.png',
        category: RewardCategory.dining,
      ),
      const RewardItemEntity(
        id: 'r3',
        title: 'Airport Lounge Access',
        description: 'Relax in style before your flight',
        pointsRequired: 8000,
        imageUrl: 'https://img.icons8.com/color/96/airport-lounge.png',
        category: RewardCategory.travel,
      ),
      const RewardItemEntity(
        id: 'r4',
        title: '\$10 Cashback',
        description: 'Instantly credited to your account',
        pointsRequired: 1500,
        imageUrl: 'https://img.icons8.com/color/96/cash-in-hand.png',
        category: RewardCategory.cashback,
      ),
    ];

    final redemptions = [
      RewardRedemption(
        id: 'tr1',
        rewardTitle: 'Netflix 1 Month Subscription',
        date: DateTime.now().subtract(const Duration(days: 15)),
        pointsSpent: 1200,
      ),
    ];

    emit(RewardsLoaded(
      currentPoints: 4250,
      tier: 'Gold',
      progressToNextTier: 0.65,
      catalog: catalog,
      redemptions: redemptions,
    ));
  }

  void _onRedeemReward(RedeemRewardEvent event, Emitter<RewardsState> emit) {
    if (state is RewardsLoaded) {
      final current = state as RewardsLoaded;

      try {
        final reward = current.catalog.firstWhere(
          (r) => r.id == event.rewardId,
          orElse: () => throw Exception('Reward not found'),
        );

        if (current.currentPoints >= reward.pointsRequired) {
          final newPoints = current.currentPoints - reward.pointsRequired;
          final newRedemption = RewardRedemption(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            rewardTitle: reward.title,
            date: DateTime.now(),
            pointsSpent: reward.pointsRequired,
          );

          final updatedRedemptions = [newRedemption, ...current.redemptions];

          emit(RedeemSuccess(
            'Successfully redeemed ${reward.title}!',
            currentPoints: newPoints,
            tier: current.tier,
            progressToNextTier: current.progressToNextTier,
            catalog: current.catalog,
            redemptions: updatedRedemptions,
          ));
          
          // Re-emit as plain RewardsLoaded to stabilize the state
          emit(RewardsLoaded(
            currentPoints: newPoints,
            tier: current.tier,
            progressToNextTier: current.progressToNextTier,
            catalog: current.catalog,
            redemptions: updatedRedemptions,
          ));
        } else {
          emit(RedeemFailure(
            'Insufficient points to redeem this reward.',
            currentPoints: current.currentPoints,
            tier: current.tier,
            progressToNextTier: current.progressToNextTier,
            catalog: current.catalog,
            redemptions: current.redemptions,
          ));
          emit(current); // Restore original state
        }
      } catch (e) {
        emit(RedeemFailure(
          e.toString(),
          currentPoints: current.currentPoints,
          tier: current.tier,
          progressToNextTier: current.progressToNextTier,
          catalog: current.catalog,
          redemptions: current.redemptions,
        ));
        emit(current);
      }
    }
  }
}
