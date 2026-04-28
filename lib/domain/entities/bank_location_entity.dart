enum LocationType { atm, branch }

class BankLocationEntity {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final LocationType type;
  final bool isOpen247;
  final bool hasCashDeposit;
  final String openingHours; // e.g., "09:00 - 17:00"
  final double distance; // in km

  const BankLocationEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.type,
    this.isOpen247 = false,
    this.hasCashDeposit = false,
    this.openingHours = "09:00 - 17:00",
    this.distance = 0.0,
  });

  BankLocationEntity copyWith({double? distance}) {
    return BankLocationEntity(
      id: id,
      name: name,
      address: address,
      lat: lat,
      lng: lng,
      type: type,
      isOpen247: isOpen247,
      hasCashDeposit: hasCashDeposit,
      openingHours: openingHours,
      distance: distance ?? this.distance,
    );
  }
}
