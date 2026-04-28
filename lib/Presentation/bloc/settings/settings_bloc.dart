import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class LoadSettingsEvent extends SettingsEvent {}

class TogglePrivacyModeEvent extends SettingsEvent {
  final bool hideBalance;
  const TogglePrivacyModeEvent(this.hideBalance);
  @override
  List<Object?> get props => [hideBalance];
}

class UpdateDailyLimitEvent extends SettingsEvent {
  final double limit;
  const UpdateDailyLimitEvent(this.limit);
  @override
  List<Object?> get props => [limit];
}

class SettingsState extends Equatable {
  final bool hideBalance;
  final double dailyTransferLimit;

  const SettingsState({
    required this.hideBalance,
    required this.dailyTransferLimit,
  });

  @override
  List<Object?> get props => [hideBalance, dailyTransferLimit];

  SettingsState copyWith({
    bool? hideBalance,
    double? dailyTransferLimit,
  }) {
    return SettingsState(
      hideBalance: hideBalance ?? this.hideBalance,
      dailyTransferLimit: dailyTransferLimit ?? this.dailyTransferLimit,
    );
  }
}

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState(hideBalance: false, dailyTransferLimit: 5000.0)) {
    on<LoadSettingsEvent>((event, emit) {
      // Load from prefs if needed
    });
    on<TogglePrivacyModeEvent>((event, emit) {
      emit(state.copyWith(hideBalance: event.hideBalance));
    });
    on<UpdateDailyLimitEvent>((event, emit) {
      emit(state.copyWith(dailyTransferLimit: event.limit));
    });
  }
}
