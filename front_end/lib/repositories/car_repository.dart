import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_end/models/car_telemetry.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class CarRepository {
  final WebSocketChannel _channel;

  CarRepository(String url)
      : _channel = WebSocketChannel.connect(Uri.parse(url));

  Stream<CarTelemetry> get telemetryStream {
    return _channel.stream.map((event) {
      final jsonMap = jsonDecode(event as String);
      return CarTelemetry.fromJson(jsonMap);
    });
  }

  void dispose() {
    _channel.sink.close();
  }
}

final carRepositoryProvider = Provider<CarRepository>((ref) {
  final repository = CarRepository('ws://10.163.178.170:8765');

  ref.onDispose(() {
    repository.dispose();
  });

  return repository;
});

final telemetryProvider = StreamProvider<CarTelemetry>((ref) {
  final repository = ref.watch(carRepositoryProvider);
  return repository.telemetryStream;
});
