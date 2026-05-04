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

  factory EnergyData.fromFirebase(String key, Map<dynamic, dynamic> data) {
    final keyInt = int.tryParse(key) ?? 0;

    final dateTime = keyInt > 1000000000000
        ? DateTime.fromMillisecondsSinceEpoch(keyInt)
        : DateTime.fromMillisecondsSinceEpoch(keyInt * 1000);

    return EnergyData(
      timestamp: key,
      dateTime: dateTime,
      power: _toDouble(data['power_W']),
      energy: _toDouble(data['energy_kWh']),
      voltage: _toDouble(data['voltage_V']),
      current: _toDouble(data['current_A']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}