import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/savings_goal.dart';

abstract class SavingsGoalEvent extends Equatable {
  const SavingsGoalEvent();
  @override
  List<Object?> get props => [];
}

class LoadSavingsGoalsEvent extends SavingsGoalEvent {}

class AddSavingsGoalEvent extends SavingsGoalEvent {
  final SavingsGoalEntity goal;
  const AddSavingsGoalEvent(this.goal);
  @override
  List<Object?> get props => [goal];
}

class SavingsGoalState extends Equatable {
  final List<SavingsGoalEntity> goals;
  final bool isLoading;

  const SavingsGoalState({this.goals = const [], this.isLoading = false});

  @override
  List<Object?> get props => [goals, isLoading];
}

class SavingsGoalBloc extends Bloc<SavingsGoalEvent, SavingsGoalState> {
  SavingsGoalBloc() : super(const SavingsGoalState()) {
    on<LoadSavingsGoalsEvent>((event, emit) {
      emit(const SavingsGoalState(isLoading: true));
      // Mock goals
      final goals = [
        SavingsGoalEntity(
          id: '1',
          title: 'New MacBook Pro',
          targetAmount: 3000,
          currentAmount: 1800,
          deadline: DateTime.now().add(const Duration(days: 90)),
          icon: '💻',
        ),
        SavingsGoalEntity(
          id: '2',
          title: 'Summer Vacation',
          targetAmount: 5000,
          currentAmount: 4200,
          deadline: DateTime.now().add(const Duration(days: 45)),
          icon: '🏖️',
        ),
        SavingsGoalEntity(
          id: '3',
          title: 'Emergency Fund',
          targetAmount: 10000,
          currentAmount: 3000,
          deadline: DateTime.now().add(const Duration(days: 365)),
          icon: '🛡️',
        ),
      ];
      emit(SavingsGoalState(goals: goals, isLoading: false));
    });
  }
}
