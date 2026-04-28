class SecurityActivity {
  final String id;
  final String deviceName;
  final String location;
  final String ipAddress;
  final DateTime timestamp;
  final bool isCurrentDevice;

  const SecurityActivity({
    required this.id,
    required this.deviceName,
    required this.location,
    required this.ipAddress,
    required this.timestamp,
    this.isCurrentDevice = false,
  });
}
