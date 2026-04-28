import 'package:equatable/equatable.dart';

abstract class LocatorEvent extends Equatable {
  const LocatorEvent();

  @override
  List<Object?> get props => [];
}

class FetchBankLocationsEvent extends LocatorEvent {}

class FilterLocationsEvent extends LocatorEvent {
  final bool onlyAtms;
  final bool onlyBranches;
  final bool openNow;
  final bool hasDeposit;

  const FilterLocationsEvent({
    required this.onlyAtms,
    required this.onlyBranches,
    required this.openNow,
    required this.hasDeposit,
  });

  @override
  List<Object?> get props => [onlyAtms, onlyBranches, openNow, hasDeposit];
}
