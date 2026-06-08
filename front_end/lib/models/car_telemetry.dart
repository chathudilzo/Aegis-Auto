class CarTelemetry {
  final int rpm;
  final int speed;
  final double engineTemp;
  final Map<String, int> tirePressure;
  final int fuelLevel;
  final Map<String, int> brakeTemp;
  final Map<String, int> suspension;
  final int batterySoh;
  final List<String> dtcs;

  CarTelemetry({
    required this.rpm,
    required this.speed,
    required this.engineTemp,
    required this.tirePressure,
    required this.fuelLevel,
    required this.brakeTemp,
    required this.suspension,
    required this.batterySoh,
    required this.dtcs,
  });

  factory CarTelemetry.fromJson(Map<String, dynamic> json) {
    return CarTelemetry(
      rpm: json['rpm'] ?? 0,
      speed: json['speed'] ?? 0,
      engineTemp: (json['engine_temp'] ?? 0.0).toDouble(),
      tirePressure: Map<String, int>.from(json['tire_pressure'] ?? {}),
      fuelLevel: json['fuel_level'] ?? 0,
      brakeTemp: Map<String, int>.from(json['brake_temp'] ?? {}),
      suspension: Map<String, int>.from(json['suspension'] ?? {}),
      batterySoh: json['battery_soh'] ?? 100,
      dtcs: List<String>.from(json['dtcs'] ?? []),
    );
  }
}
