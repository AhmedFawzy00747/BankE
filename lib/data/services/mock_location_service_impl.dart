import 'package:contr_project/domain/entities/bank_location_entity.dart';

import '../../domain/services/location_service.dart';

class MockLocationServiceImpl implements LocationService {
  // Default to New York (Trusted Zone)
  Map<String, double> _currentLocation = {'lat': 40.7128, 'lng': -74.0060};

  @override
  Future<Map<String, double>> getCurrentLocation() async {
    // Artificial delay measuring GPS ping
    await Future.delayed(const Duration(milliseconds: 500));
    return _currentLocation;
  }

  @override
  List<Map<String, double>> getTrustedZones() {
    return [
      {'lat': 40.7128, 'lng': -74.0060}, // New York
      {'lat': 34.0522, 'lng': -118.2437}, // Los Angeles
    ];
  }

  @override
  Future<void> setMockLocation(double lat, double lng) async {
    _currentLocation = {'lat': lat, 'lng': lng};
  }

  @override
  Future<List<BankLocationEntity>> getNearbyBankLocations() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final current = await getCurrentLocation();

    final List<BankLocationEntity> rawLocations = [
      const BankLocationEntity(
        id: 'loc_1',
        name: 'Main Street ATM',
        address: '123 Main St, New York',
        lat: 40.7138,
        lng: -74.0070,
        type: LocationType.atm,
        isOpen247: true,
        hasCashDeposit: true,
      ),
      const BankLocationEntity(
        id: 'loc_2',
        name: 'Downtown Branch',
        address: '55 Broadway, New York',
        lat: 40.7078,
        lng: -74.0110,
        type: LocationType.branch,
        openingHours: '08:30 - 18:00',
      ),
      const BankLocationEntity(
        id: 'loc_3',
        name: 'Queens Plaza ATM',
        address: 'Queens Blvd, NY',
        lat: 40.7489,
        lng: -73.9392,
        type: LocationType.atm,
        isOpen247: true,
      ),
      const BankLocationEntity(
        id: 'loc_4',
        name: 'Brooklyn Hub',
        address: 'Atlantic Ave, Brooklyn',
        lat: 40.6841,
        lng: -73.9786,
        type: LocationType.branch,
        hasCashDeposit: true,
      ),
    ];

    // Calculate distances (Simplified Euclidean for mock purposes)
    return rawLocations.map((loc) {
      final double distance = _calculateDistance(
          current['lat']!, current['lng']!, loc.lat, loc.lng);
      return loc.copyWith(distance: distance);
    }).toList()
      ..sort((a, b) => a.distance.compareTo(b.distance));
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    // 1 degree is roughly 111km
    final double latDiff = (lat1 - lat2).abs();
    final double lonDiff = (lon1 - lon2).abs();
    return (latDiff + lonDiff) * 111.0;
  }
}
