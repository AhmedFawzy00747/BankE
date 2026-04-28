import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/services/location_service.dart';
import '../../../domain/entities/bank_location_entity.dart';
import 'locator_event.dart';
import 'locator_state.dart';

class LocatorBloc extends Bloc<LocatorEvent, LocatorState> {
  final LocationService locationService;

  LocatorBloc({required this.locationService}) : super(LocatorInitial()) {
    on<FetchBankLocationsEvent>(_onFetchLocations);
    on<FilterLocationsEvent>(_onFilterLocations);
  }

  Future<void> _onFetchLocations(FetchBankLocationsEvent event, Emitter<LocatorState> emit) async {
    emit(LocatorLoading());
    try {
      final locations = await locationService.getNearbyBankLocations();
      emit(LocatorLoaded(locations, locations));
    } catch (e) {
      emit(LocatorError(e.toString()));
    }
  }

  void _onFilterLocations(FilterLocationsEvent event, Emitter<LocatorState> emit) {
    if (state is LocatorLoaded) {
      final currentState = state as LocatorLoaded;
      
      final filtered = currentState.locations.where((loc) {
        if (event.onlyAtms && loc.type != LocationType.atm) return false;
        if (event.onlyBranches && loc.type != LocationType.branch) return false;
        if (event.hasDeposit && !loc.hasCashDeposit) return false;
        if (event.openNow && !loc.isOpen247) {
          // Simple mock: if it's not 24/7, assume it's open for now for demo
          // In a real app, check openingHours vs current time
        }
        return true;
      }).toList();

      emit(LocatorLoaded(currentState.locations, filtered));
    }
  }
}
