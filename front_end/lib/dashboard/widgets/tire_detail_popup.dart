import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_end/repositories/car_repository.dart';

class TireDetailDialog extends ConsumerWidget {
  const TireDetailDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telemetryAsyncValue = ref.watch(telemetryProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: telemetryAsyncValue.when(
        data: (telemetry) {
          final tires = telemetry.tirePressure;
          return Stack(
            alignment: Alignment.topRight,
            children: [
              _buildChassisTireGrid(tires),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (err, stack) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildChassisTireGrid(Map<String, int> tires) {
    return Container(
      width: 280,
      height: 380,
      decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(color: Colors.cyanAccent.withOpacity(0.1), blurRadius: 20)
          ]),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 80,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white24, width: 2),
              ),
              child: Center(
                child: Container(
                  width: 4,
                  height: 180,
                  color: Colors.white12,
                ),
              ),
            ),
          ),
          Positioned(
              top: 40,
              left: 20,
              child: _buildChassisWheelNode('FL', tires['fl'] ?? 0)),
          Positioned(
              top: 40,
              right: 20,
              child: _buildChassisWheelNode('FR', tires['fr'] ?? 0)),
          Positioned(
              bottom: 40,
              left: 20,
              child: _buildChassisWheelNode('RL', tires['rl'] ?? 0)),
          Positioned(
              bottom: 40,
              right: 20,
              child: _buildChassisWheelNode('RR', tires['rr'] ?? 0)),
        ],
      ),
    );
  }

  Widget _buildChassisWheelNode(String label, int pressure) {
    Color statusColor = Colors.greenAccent;
    if (pressure < 30 && pressure >= 25) {
      statusColor = Colors.amberAccent;
    } else if (pressure < 25 || pressure > 40) {
      statusColor = Colors.redAccent;
    }

    return Column(
      children: [
        Container(
          width: 28,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: statusColor, width: 2),
            boxShadow: [
              if (statusColor != Colors.greenAccent)
                BoxShadow(color: statusColor.withOpacity(0.4), blurRadius: 8),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                  color: statusColor.withOpacity(0.8),
                  fontSize: 10,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text('$pressure',
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const Text('PSI',
            style: TextStyle(
                fontSize: 9,
                color: Colors.white54,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}
