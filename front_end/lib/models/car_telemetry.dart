class CarTelemetry {
  final int rpm;
  final int speed;
  final double engineTemp;
  final Map<String, int> tirePressure;
  final int fuelLevel;

  CarTelemetry({
    required this.rpm,
    required this.speed,
    required this.engineTemp,
    required this.tirePressure,
    required this.fuelLevel,
  });

  factory CarTelemetry.fromJson(Map<String, dynamic> json) {
    return CarTelemetry(
      rpm: json['rpm'] ?? 0,
      speed: json['speed'] ?? 0,
      engineTemp: (json['engine_temp'] ?? 0.0).toDouble(),
      tirePressure: Map<String, int>.from(json['tire_pressure'] ?? {}),
      fuelLevel: json['fuel_level'] ?? 0,
    );
  }
}
