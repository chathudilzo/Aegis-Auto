import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_end/dashboard/views/dashboard_screen.dart';
import 'package:front_end/repositories/car_repository.dart';

void main() {
  runApp(const ProviderScope(child: AegisAutoApp()));
}

class AegisAutoApp extends StatelessWidget {
  const AegisAutoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: const DashboardTestScreen(),
    );
  }
}
