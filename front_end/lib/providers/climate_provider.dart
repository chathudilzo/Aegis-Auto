import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClimateState {
  final double driverTemp;
  final double passengerTemp;
  final int fanSpeed;
  final bool isAcOn;
  final int driverSeatHeater;

  ClimateState({
    this.driverTemp = 22.0,
    this.passengerTemp = 22.0,
    this.fanSpeed = 2,
    this.isAcOn = true,
    this.driverSeatHeater = 0,
  });

  ClimateState copyWith({
    double? driverTemp,
    double? passengerTemp,
    int? fanSpeed,
    bool? isAcOn,
    int? driverSeatHeater,
  }) {
    return ClimateState(
      driverTemp: driverTemp ?? this.driverTemp,
      passengerTemp: passengerTemp ?? this.passengerTemp,
      fanSpeed: fanSpeed ?? this.fanSpeed,
      isAcOn: isAcOn ?? this.isAcOn,
      driverSeatHeater: driverSeatHeater ?? this.driverSeatHeater,
    );
  }
}

class ClimateNotifier extends StateNotifier<ClimateState> {
  ClimateNotifier() : super(ClimateState());

  void adjustDriverTemp(double change) {
    final newTemp = (state.driverTemp + change).clamp(16.0, 30.0);
    state = state.copyWith(driverTemp: newTemp);
  }

  void adjustPassengerTemp(double change) {
    final newTemp = (state.passengerTemp + change).clamp(16.0, 30.0);
    state = state.copyWith(passengerTemp: newTemp);
  }

  void setFanSpeed(int speed) {
    state = state.copyWith(fanSpeed: speed.clamp(0, 5));
  }

  void toggleAc() {
    state = state.copyWith(isAcOn: !state.isAcOn);
  }

  void cycleSeatHeater() {
    final nextState = (state.driverSeatHeater + 1) % 4;
    state = state.copyWith(driverSeatHeater: nextState);
  }
}

final climateProvider =
    StateNotifierProvider<ClimateNotifier, ClimateState>((ref) {
  return ClimateNotifier();
});
