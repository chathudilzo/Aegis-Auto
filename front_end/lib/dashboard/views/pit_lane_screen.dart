import 'package:flutter/material.dart';
import 'package:front_end/models/car_telemetry.dart';

class PitLaneDiagnosticsScreen extends StatelessWidget {
  final CarTelemetry telemetry;

  const PitLaneDiagnosticsScreen({super.key, required this.telemetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF070B11),
      padding: const EdgeInsets.all(32.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SYSTEM DIAGNOSTICS // PIT MODE',
                  style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3),
                ),
                const SizedBox(height: 24),
                _buildSystemRow('BATTERY PACK STATUS',
                    '${telemetry.batterySoh}% SOH', Colors.cyanAccent),
                _buildSystemRow(
                    'COOLANT THERMAL INDEX',
                    '${telemetry.engineTemp}°C',
                    telemetry.engineTemp > 105
                        ? Colors.redAccent
                        : Colors.white),
                _buildSystemRow('FUEL CAPACITY CELL',
                    '${telemetry.fuelLevel}% LYT', Colors.orangeAccent),
                const Spacer(),
                _buildDtcLogModule(telemetry.dtcs),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: _buildDiagnosticCarChassis(
                telemetry.tirePressure,
                telemetry.brakeTemp,
                telemetry.suspension,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5)),
          Text(value,
              style: TextStyle(
                  color: valueColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Courier')),
        ],
      ),
    );
  }

  Widget _buildDtcLogModule(List<String> codes) {
    bool hasFaults = codes.isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasFaults
            ? Colors.redAccent.withOpacity(0.05)
            : Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color:
                hasFaults ? Colors.redAccent.withOpacity(0.3) : Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                  hasFaults ? Icons.report_problem : Icons.check_circle_outline,
                  color: hasFaults ? Colors.redAccent : Colors.greenAccent,
                  size: 16),
              const SizedBox(width: 8),
              Text(
                hasFaults ? 'ACTIVE FAULT LOG DETECTED' : 'OBD MODULE SECURE',
                style: TextStyle(
                    color: hasFaults ? Colors.redAccent : Colors.greenAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1),
              ),
            ],
          ),
          if (hasFaults) ...[
            const SizedBox(height: 12),
            Text(
              'SYS CODE: ${codes.join(", ")} - EXCESS THERMAL BRAKE LOAD',
              style: const TextStyle(
                  color: Colors.white70, fontSize: 12, fontFamily: 'Courier'),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildDiagnosticCarChassis(
      Map<String, int> tires, Map<String, int> brakes, Map<String, int> susp) {
    return SizedBox(
      width: 320,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 80,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: Colors.blueAccent.withOpacity(0.15), width: 1),
            ),
          ),
          Positioned(
              top: 0,
              left: 10,
              child: _buildCornerNode(
                  'FL', tires['fl'] ?? 0, brakes['fl'] ?? 0, susp['fl'] ?? 0)),
          Positioned(
              top: 0,
              right: 10,
              child: _buildCornerNode(
                  'FR', tires['fr'] ?? 0, brakes['fr'] ?? 0, susp['fr'] ?? 0)),
          Positioned(
              bottom: 0,
              left: 10,
              child: _buildCornerNode(
                  'RL', tires['rl'] ?? 0, brakes['rl'] ?? 0, susp['rl'] ?? 0)),
          Positioned(
              bottom: 0,
              right: 10,
              child: _buildCornerNode(
                  'RR', tires['rr'] ?? 0, brakes['rr'] ?? 0, susp['rr'] ?? 0)),
        ],
      ),
    );
  }

  Widget _buildCornerNode(String key, int psi, int brakeTemp, int compression) {
    Color brakeColor = brakeTemp > 380
        ? Colors.redAccent
        : (brakeTemp > 250 ? Colors.amberAccent : Colors.cyanAccent);

    return Container(
      width: 110,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(key,
              style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
          const Divider(color: Colors.white12, height: 12),
          Text('$psi PSI',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text('$brakeTemp°C RTR',
              style: TextStyle(
                  color: brakeColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text('$compression% travel',
              style: const TextStyle(color: Colors.white54, fontSize: 10)),
        ],
      ),
    );
  }
}
