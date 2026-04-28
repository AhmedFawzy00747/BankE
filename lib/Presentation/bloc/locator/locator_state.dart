import 'package:equatable/equatable.dart';
import '../../../domain/entities/bank_location_entity.dart';

abstract class LocatorState extends Equatable {
  const LocatorState();

  @override
  List<Object?> get props => [];
}

class LocatorInitial extends LocatorState {}

class LocatorLoading extends LocatorState {}

class LocatorLoaded extends LocatorState {
  final List<BankLocationEntity> locations;
  final List<BankLocationEntity> filteredLocations;

  const LocatorLoaded(this.locations, this.filteredLocations);

  @override
  List<Object?> get props => [locations, filteredLocations];
}

class LocatorError extends LocatorState {
  final String message;

  const LocatorError(this.message);

  @override
  List<Object?> get props => [message];
}
