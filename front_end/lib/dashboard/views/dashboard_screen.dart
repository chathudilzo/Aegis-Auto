import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_end/repositories/car_repository.dart';
import 'package:o3d/o3d.dart';

class DashboardTestScreen extends ConsumerStatefulWidget {
  const DashboardTestScreen({super.key});

  @override
  ConsumerState<DashboardTestScreen> createState() =>
      _DashboardTestScreenState();
}

class _DashboardTestScreenState extends ConsumerState<DashboardTestScreen> {
  late O3DController _o3dController;

  @override
  void initState() {
    super.initState();
    _o3dController = O3DController();
  }

  @override
  Widget build(BuildContext context) {
    final telemetryAsyncValue = ref.watch(telemetryProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          O3D(
            src: 'assets/mclaren_ready.glb',
            controller: _o3dController,
            ar: false,
            autoPlay: true,
            autoRotate: false,
            cameraControls: true,
          ),
          SafeArea(
            child: telemetryAsyncValue.when(
              data: (telemetry) {
                if (telemetry.speed > 0) {
                  _o3dController.play();
                } else {
                  _o3dController.pause();
                }

                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AEGIS AUTO',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent.shade400,
                            letterSpacing: 2),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.greenAccent),
                        ),
                        child: const Text(
                          'LIVE TELEMETRY LINKED',
                          style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatCard('SPEED', '${telemetry.speed}', 'km/h'),
                          _buildStatCard(
                              'ENGINE RPM', '${telemetry.rpm}', 'RPM'),
                          _buildStatCard(
                              'TEMP', '${telemetry.engineTemp}', '°C'),
                        ],
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(
                  child: CircularProgressIndicator(color: Colors.redAccent)),
              error: (err, stack) => Center(
                child: Text(
                  'LINK DROPPED\nCheck Python Server\n$err',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String unit) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          Text(unit,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
        ],
      ),
    );
  }
}
