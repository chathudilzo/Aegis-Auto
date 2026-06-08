import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_end/dashboard/views/full_map_screen.dart';
import 'package:front_end/dashboard/views/media_screen.dart';
import 'package:front_end/dashboard/views/quick_access_scren.dart';
import 'package:front_end/providers/nav_provider.dart';
import 'dashboard_screen.dart';

class HmiShell extends ConsumerWidget {
  const HmiShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentNavIndexProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF070B11),
      body: Row(
        children: [
          Container(
            width: 75,
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildNavIcon(ref, Icons.speed, 0, currentIndex, 'HUD'),
                const SizedBox(height: 32),
                _buildNavIcon(ref, Icons.grid_view, 1, currentIndex, 'APPS'),
                const SizedBox(height: 32),
                _buildNavIcon(ref, Icons.map, 2, currentIndex, 'MAP'),
                const SizedBox(height: 32),
                _buildNavIcon(ref, Icons.music_note, 3, currentIndex, 'MEDIA'),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: currentIndex,
              children: [
                const DashboardTestScreen(),
                const QuickAccessScreen(),
                FullMapNavigationScreen(),
                MediaScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(
      WidgetRef ref, IconData icon, int index, int currentIndex, String label) {
    final isActive = index == currentIndex;
    return GestureDetector(
      onTap: () => ref.read(currentNavIndexProvider.notifier).state = index,
      child: Column(
        children: [
          Icon(icon,
              size: 32, color: isActive ? Colors.cyanAccent : Colors.white24),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                  color: isActive ? Colors.cyanAccent : Colors.white24,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                  color: Colors.cyanAccent,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.cyanAccent.withOpacity(0.5),
                        blurRadius: 8)
                  ]),
            )
        ],
      ),
    );
  }

  Widget _buildPlaceholderScreen(String title, Color color) {
    return Center(
      child: Text(title,
          style: TextStyle(
              color: color,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 4)),
    );
  }
}
