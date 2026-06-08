import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_end/dashboard/widgets/hud_overlay.dart';
import 'package:front_end/repositories/car_repository.dart';
import 'package:o3d/o3d.dart';

import 'pit_lane_screen.dart';

enum HmiMode { cockpit, pitLane }

class DashboardTestScreen extends ConsumerStatefulWidget {
  const DashboardTestScreen({super.key});

  @override
  ConsumerState<DashboardTestScreen> createState() =>
      _DashboardTestScreenState();
}

class _DashboardTestScreenState extends ConsumerState<DashboardTestScreen> {
  late O3DController _o3dController;
  HmiMode _currentMode = HmiMode.cockpit;

  @override
  void initState() {
    super.initState();
    _o3dController = O3DController();
  }

  @override
  Widget build(BuildContext context) {
    final telemetryAsyncValue = ref.watch(telemetryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF070B11),
      body: Stack(
        children: [
          if (_currentMode == HmiMode.cockpit)
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
                if (telemetry.speed > 0 && _currentMode == HmiMode.cockpit) {
                  _o3dController.play();
                } else {
                  _o3dController.pause();
                }

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _currentMode == HmiMode.cockpit
                      ? TelemetryHudOverlay(telemetry: telemetry)
                      : PitLaneDiagnosticsScreen(telemetry: telemetry),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.cyanAccent),
              ),
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
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(
              child: _buildHmiTabBar(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHmiTabBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabButton('COCKPIT HUD', HmiMode.cockpit),
          _buildTabButton('PIT DIAGNOSTICS', HmiMode.pitLane),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, HmiMode mode) {
    final bool isActive = _currentMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentMode = mode;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.blueAccent.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? Colors.cyanAccent.withOpacity(0.5)
                : Colors.transparent,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.cyanAccent : Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
