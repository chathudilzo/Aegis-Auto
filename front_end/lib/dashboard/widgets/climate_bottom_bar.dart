import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_end/providers/climate_provider.dart';

class ClimateBottomBar extends ConsumerWidget {
  const ClimateBottomBar({super.key});

  Color _getTempColor(double temp) {
    if (temp < 19.0) return Colors.lightBlueAccent;
    if (temp > 24.0) return Colors.deepOrangeAccent;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final climateState = ref.watch(climateProvider);
    final notifier = ref.read(climateProvider.notifier);

    return Container(
      height: 90,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        border: Border(top: BorderSide(color: Colors.white10, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTempControl(
            temp: climateState.driverTemp,
            onDecrease: () => notifier.adjustDriverTemp(-0.5),
            onIncrease: () => notifier.adjustDriverTemp(0.5),
          ),
          IconButton(
            icon: Icon(
              Icons.chair_alt,
              color: climateState.driverSeatHeater > 0
                  ? Colors.deepOrangeAccent
                  : Colors.white38,
            ),
            onPressed: () => notifier.cycleSeatHeater(),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => notifier.toggleAc(),
                  child: Text(
                    "A/C",
                    style: TextStyle(
                      color: climateState.isAcOn
                          ? Colors.lightBlueAccent
                          : Colors.white38,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 32),
                IconButton(
                  icon: const Icon(Icons.ac_unit, color: Colors.white54),
                  onPressed: () =>
                      notifier.setFanSpeed(climateState.fanSpeed - 1),
                ),
                Row(
                  children: List.generate(5, (index) {
                    final isActive = index < climateState.fanSpeed;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.purpleAccent : Colors.white12,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                    color: Colors.purpleAccent.withOpacity(0.5),
                                    blurRadius: 8)
                              ]
                            : [],
                      ),
                    );
                  }),
                ),
                IconButton(
                  icon: const Icon(Icons.air, color: Colors.white54),
                  onPressed: () =>
                      notifier.setFanSpeed(climateState.fanSpeed + 1),
                ),
              ],
            ),
          ),
          const IconButton(
              icon: Icon(Icons.air, color: Colors.white38), onPressed: null),
          _buildTempControl(
            temp: climateState.passengerTemp,
            onDecrease: () => notifier.adjustPassengerTemp(-0.5),
            onIncrease: () => notifier.adjustPassengerTemp(0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildTempControl(
      {required double temp,
      required VoidCallback onDecrease,
      required VoidCallback onIncrease}) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_drop_down,
              color: Colors.white54, size: 36),
          onPressed: onDecrease,
        ),
        SizedBox(
          width: 70,
          child: Text(
            "${temp.toStringAsFixed(1)}°",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: _getTempColor(temp),
              shadows: [
                BoxShadow(
                    color: _getTempColor(temp).withOpacity(0.4), blurRadius: 10)
              ],
            ),
          ),
        ),
        IconButton(
          icon:
              const Icon(Icons.arrow_drop_up, color: Colors.white54, size: 36),
          onPressed: onIncrease,
        ),
      ],
    );
  }
}
