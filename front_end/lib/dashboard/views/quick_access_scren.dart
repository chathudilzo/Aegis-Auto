import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_end/providers/nav_provider.dart';
import 'package:front_end/repositories/car_repository.dart';

class QuickAccessScreen extends ConsumerWidget {
  const QuickAccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'QUICK ACCESS HUB',
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 2),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildCard(
                    title: 'NAVIGATION',
                    color: Colors.blueAccent.withOpacity(0.1),
                    borderColor: Colors.blueAccent,
                    icon: Icons.map_outlined,
                    onTap: () =>
                        ref.read(currentNavIndexProvider.notifier).state = 2,
                    child: const Center(
                        child: Text('Map View Active',
                            style: TextStyle(color: Colors.white54))),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildTelemetryCard(ref),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildCard(
                    title: 'MEDIA',
                    color: Colors.purpleAccent.withOpacity(0.1),
                    borderColor: Colors.purpleAccent,
                    icon: Icons.music_note,
                    onTap: () =>
                        ref.read(currentNavIndexProvider.notifier).state = 3,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.album, size: 64, color: Colors.white24),
                          SizedBox(height: 16),
                          Text('Synthwave Mix Vol 4',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          Text('Playing...',
                              style: TextStyle(
                                  color: Colors.purpleAccent, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
      {required String title,
      required Color color,
      required Color borderColor,
      required IconData icon,
      required VoidCallback onTap,
      required Widget child}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor.withOpacity(0.5), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(icon, color: borderColor),
                  const SizedBox(width: 8),
                  Text(title,
                      style: TextStyle(
                          color: borderColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1)),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryCard(WidgetRef ref) {
    final telemetryAsync = ref.watch(telemetryProvider);

    return _buildCard(
      title: 'VEHICLE STATUS',
      color: Colors.cyanAccent.withOpacity(0.05),
      borderColor: Colors.cyanAccent,
      icon: Icons.electric_car,
      onTap: () => ref.read(currentNavIndexProvider.notifier).state = 0,
      child: telemetryAsync.when(
        data: (data) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${data.speed}',
                  style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      height: 1)),
              const Text('km/h',
                  style: TextStyle(
                      color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('BATTERY SOH',
                      style: TextStyle(color: Colors.white54, fontSize: 12)),
                  Text('${data.batterySoh}%',
                      style: const TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('MODEL',
                      style: TextStyle(color: Colors.white54, fontSize: 12)),
                  const Text('AEGIS M1',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.cyanAccent)),
        error: (_, __) => const Center(
            child: Text('OFFLINE', style: TextStyle(color: Colors.redAccent))),
      ),
    );
  }
}
