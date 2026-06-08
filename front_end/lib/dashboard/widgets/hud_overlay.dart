import 'dart:math';

import 'package:flutter/material.dart';
import 'package:front_end/dashboard/widgets/tire_detail_popup.dart';
import 'package:front_end/models/car_telemetry.dart';

class TelemetryHudOverlay extends StatelessWidget {
  final CarTelemetry telemetry;

  const TelemetryHudOverlay({super.key, required this.telemetry});

  @override
  Widget build(BuildContext context) {
    final bool isRpmCritical = telemetry.rpm > 6500;
    final bool isTempCritical = telemetry.engineTemp > 105;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isRpmCritical || isTempCritical)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.redAccent.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2)
                ],
              ),
              child: const Text(
                'CRITICAL SYSTEM WARNING',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2),
              ),
            )
          else
            const SizedBox(height: 32),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildLeftGauge(
                    telemetry.speed, telemetry.engineTemp, isTempCritical),
                const Spacer(flex: 3),
                _buildRightGauge(context, telemetry.rpm, isRpmCritical,
                    telemetry.tirePressure),
              ],
            ),
          ),
          const Text(
            'AEGIS OS v1.0 // LINK SECURE',
            style: TextStyle(
                color: Colors.cyanAccent,
                fontSize: 10,
                letterSpacing: 4,
                fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  Widget _buildLeftGauge(int speed, double temp, bool isTempCritical) {
    return SizedBox(
      width: 360,
      height: 360,
      child: CustomPaint(
        painter: NeonGaugePainter(
          progress: speed / 300,
          coreColor: Colors.cyanAccent,
          glowColor: Colors.blueAccent.withOpacity(0.6),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$speed',
                style: const TextStyle(
                    fontSize: 110,
                    fontWeight: FontWeight.w300,
                    height: 1.0,
                    color: Colors.white)),
            const Text('km/h',
                style: TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 20,
                    letterSpacing: 3,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                  color: isTempCritical
                      ? Colors.redAccent.withOpacity(0.2)
                      : Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: isTempCritical
                          ? Colors.redAccent
                          : Colors.blueAccent.withOpacity(0.3))),
              child: Text('${temp.toStringAsFixed(1)}°C',
                  style: TextStyle(
                      color:
                          isTempCritical ? Colors.redAccent : Colors.cyanAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildChassisTireGrid(Map<String, int> tires) {
    return Container(
      width: 240,
      height: 320,
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 70,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white24, width: 2),
              ),
              child: Center(
                child: Container(
                  width: 4,
                  height: 140,
                  color: Colors.white12,
                ),
              ),
            ),
          ),
          Positioned(
            top: 30,
            left: 20,
            child: _buildChassisWheelNode('FL', tires['fl'] ?? 0),
          ),
          Positioned(
            top: 30,
            right: 20,
            child: _buildChassisWheelNode('FR', tires['fr'] ?? 0),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            child: _buildChassisWheelNode('RL', tires['rl'] ?? 0),
          ),
          Positioned(
            bottom: 30,
            right: 20,
            child: _buildChassisWheelNode('RR', tires['rr'] ?? 0),
          ),
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
          width: 24,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: statusColor, width: 2),
            boxShadow: [
              if (statusColor != Colors.greenAccent)
                BoxShadow(color: statusColor.withOpacity(0.3), blurRadius: 6),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                  color: statusColor.withOpacity(0.6),
                  fontSize: 9,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$pressure',
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const Text(
          'PSI',
          style: TextStyle(
              fontSize: 8, color: Colors.white38, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildRightGauge(BuildContext context, int rpm, bool isRpmCritical,
      Map<String, int> tires) {
    bool hasTireWarning = tires.values.any((p) => p < 30 || p > 40);

    Color glowColor = isRpmCritical
        ? Colors.redAccent.withOpacity(0.8)
        : Colors.blueAccent.withOpacity(0.6);
    Color coreColor = isRpmCritical ? Colors.redAccent : Colors.cyanAccent;
    Color buttonStatusColor =
        hasTireWarning ? Colors.redAccent : Colors.cyanAccent;

    return SizedBox(
      width: 360,
      height: 360,
      child: CustomPaint(
        painter: NeonGaugePainter(
          progress: rpm / 8000,
          coreColor: coreColor,
          glowColor: glowColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${(rpm / 1000).toStringAsFixed(1)}',
                style: TextStyle(
                    fontSize: 100,
                    fontWeight: FontWeight.w300,
                    height: 1.0,
                    color: isRpmCritical ? Colors.redAccent : Colors.white)),
            Text('x1000 RPM',
                style: TextStyle(
                    color: coreColor,
                    fontSize: 18,
                    letterSpacing: 3,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const TireDetailDialog(),
                );
              },
              child: Container(
                width: 75,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: buttonStatusColor.withOpacity(0.3)),
                ),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildChassisTireGrid(tires),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class NeonGaugePainter extends CustomPainter {
  final double progress;
  final Color coreColor;
  final Color glowColor;

  NeonGaugePainter({
    required this.progress,
    required this.coreColor,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 16;
    final rect = Rect.fromCircle(center: center, radius: radius);

    const double startAngle = 135 * (pi / 180);
    const double sweepAngle = 270 * (pi / 180);
    final double currentSweep = sweepAngle * progress;

    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, trackPaint);

    final glowPaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawArc(rect, startAngle, currentSweep, false, glowPaint);

    final corePaint = Paint()
      ..color = coreColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, currentSweep, false, corePaint);
  }

  @override
  bool shouldRepaint(covariant NeonGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.coreColor != coreColor ||
        oldDelegate.glowColor != glowColor;
  }
}
