class EnergyData {
  final String timestamp;
  final DateTime dateTime;
  final double power;
  final double energy;
  final double voltage;
  final double current;

  EnergyData({
    required this.timestamp,
    required this.dateTime,
    required this.power,
    required this.energy,
    required this.voltage,
    required this.current,
  });
}
