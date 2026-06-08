import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_end/dashboard/views/dashboard_screen.dart';
import 'package:front_end/dashboard/views/hmi_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const ProviderScope(child: AegisAutoApp()));
}

class AegisAutoApp extends StatelessWidget {
  const AegisAutoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aegis Auto',
      theme: ThemeData.dark(),
      home: const HmiShell(),
    );
  }
}
