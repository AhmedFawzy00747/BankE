import '../entities/bank_location_entity.dart';

abstract class LocationService {
  Future<Map<String, double>> getCurrentLocation();
  List<Map<String, double>> getTrustedZones();
  Future<void> setMockLocation(double lat, double lng);
  Future<List<BankLocationEntity>> getNearbyBankLocations();
}
