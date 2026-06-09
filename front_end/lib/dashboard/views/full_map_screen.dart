import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_end/repositories/car_repository.dart';

class FullMapNavigationScreen extends ConsumerStatefulWidget {
  const FullMapNavigationScreen({super.key});

  @override
  ConsumerState<FullMapNavigationScreen> createState() =>
      _FullMapNavigationScreenState();
}

class _FullMapNavigationScreenState
    extends ConsumerState<FullMapNavigationScreen> with OSMMixinObserver {
  late MapController _mapController;
  Timer? _movementTimer;
  bool _isMapInitialized = false;
  List<GeoPoint> _dynamicRoute = [];
  int _currentRouteIndex = 0;
  double _fractionalIndex = 0.0;
  GeoPoint? _currentCarPosition;

  int _breadcrumbTickCounter = 0;
  int _breadcrumbIdCounter = 0;

  final GeoPoint _startPoint = GeoPoint(latitude: 6.6826, longitude: 80.3992);
  final GeoPoint _endPoint = GeoPoint(latitude: 6.5958, longitude: 80.4998);

  @override
  void initState() {
    super.initState();
    _mapController = MapController(
      initPosition: _startPoint,
    );
    _mapController.addObserver(this);
  }

  @override
  Future<void> mapIsReady(bool isReady) async {
    if (isReady && !_isMapInitialized) {
      _isMapInitialized = true;
      try {
        RoadInfo roadInfo = await _mapController.drawRoad(
          _startPoint,
          _endPoint,
          roadType: RoadType.car,
          roadOption: const RoadOption(
            roadWidth: 30,
            roadColor: Colors.cyanAccent,
            zoomInto: true,
          ),
        );

        if (roadInfo.route.isNotEmpty) {
          setState(() {
            _dynamicRoute = roadInfo.route;
            _currentRouteIndex = 0;
            _fractionalIndex = 0.0;
            _currentCarPosition = _dynamicRoute.first;
          });

          await _mapController.addMarker(
            _currentCarPosition!,
            markerIcon: const MarkerIcon(
              icon: Icon(
                Icons.navigation,
                color: Colors.blue,
                size: 40,
              ),
            ),
          );

          _movementTimer?.cancel();
          _movementTimer =
              Timer.periodic(const Duration(milliseconds: 100), (timer) {
            _advanceVehiclePosition();
          });
        }
      } catch (e) {
        debugPrint("Error initializing road network: $e");
      }
    }
  }

  double _calculateBearing(GeoPoint start, GeoPoint end) {
    var startLat = start.latitude * math.pi / 180;
    var startLng = start.longitude * math.pi / 180;
    var endLat = end.latitude * math.pi / 180;
    var endLng = end.longitude * math.pi / 180;

    var dLng = endLng - startLng;

    var y = math.sin(dLng) * math.cos(endLat);
    var x = math.cos(startLat) * math.sin(endLat) -
        math.sin(startLat) * math.cos(endLat) * math.cos(dLng);

    var bearing = math.atan2(y, x);
    return (bearing + 2 * math.pi) % (2 * math.pi);
  }

  Future<void> _dropBreadcrumb(GeoPoint position) async {
    try {
      await _mapController.drawCircle(CircleOSM(
        key: "crumb_${_breadcrumbIdCounter++}",
        centerPoint: position,
        radius: 20.0,
        color: const Color.fromARGB(255, 19, 32, 218),
        strokeWidth: 2,
      ));
    } catch (e) {
      debugPrint("Breadcrumb skip: $e");
    }
  }

  void _advanceVehiclePosition() async {
    if (!mounted || _dynamicRoute.isEmpty || _currentCarPosition == null)
      return;

    final telemetryState = ref.read(telemetryProvider);
    final telemetry = telemetryState.valueOrNull;
    if (telemetry == null) return;

    if (telemetry.speed > 0 && _currentRouteIndex < _dynamicRoute.length - 1) {
      double speedFactor = telemetry.speed / 320.0;
      double stepSize = 0.05 + (speedFactor * 0.15);

      _fractionalIndex += stepSize;

      if (_fractionalIndex >= 1.0) {
        int integerSteps = _fractionalIndex.floor();
        _currentRouteIndex += integerSteps;
        _fractionalIndex -= integerSteps;
      }

      if (_currentRouteIndex >= _dynamicRoute.length - 1) {
        _currentRouteIndex = _dynamicRoute.length - 1;
      }

      GeoPoint newPosition = _dynamicRoute[_currentRouteIndex];
      GeoPoint oldPosition = _currentCarPosition!;

      if (oldPosition.latitude == newPosition.latitude &&
          oldPosition.longitude == newPosition.longitude) {
        return;
      }

      _breadcrumbTickCounter++;
      if (_breadcrumbTickCounter >= 1) {
        _breadcrumbTickCounter = 0;
        _dropBreadcrumb(oldPosition);
      }

      try {
        double headingAngle = _calculateBearing(oldPosition, newPosition);

        await _mapController.changeLocationMarker(
          oldLocation: oldPosition,
          newLocation: newPosition,
          angle: headingAngle,
        );

        await _mapController.moveTo(newPosition, animate: false);
        _currentCarPosition = newPosition;
      } catch (e) {
        debugPrint("Marker Update Skip: $e");
      }
    } else if (_currentRouteIndex >= _dynamicRoute.length - 1) {
      GeoPoint endPosition = _currentCarPosition!;
      GeoPoint resetPosition = _dynamicRoute.first;

      setState(() {
        _currentRouteIndex = 0;
        _fractionalIndex = 0.0;
        _breadcrumbTickCounter = 0;
        _breadcrumbIdCounter = 0;
      });

      try {
        await _mapController.removeAllCircle();

        await _mapController.changeLocationMarker(
          oldLocation: endPosition,
          newLocation: resetPosition,
          angle: 0.0,
        );

        await _mapController.moveTo(resetPosition, animate: false);
        _currentCarPosition = resetPosition;
      } catch (e) {
        debugPrint("Reset Skip: $e");
      }
    }
  }

  @override
  void dispose() {
    _movementTimer?.cancel();
    _mapController.removeAllCircle();
    _mapController.removeObserver(this);
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final telemetryAsync = ref.watch(telemetryProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          OSMFlutter(
            controller: _mapController,
            osmOption: const OSMOption(
              showZoomController: false,
              showContributorBadgeForOSM: false,
              zoomOption: ZoomOption(
                initZoom: 10,
                minZoomLevel: 8,
                maxZoomLevel: 19,
                stepZoom: 1.0,
              ),
            ),
          ),
          Positioned(
            bottom: 32,
            left: 32,
            child: telemetryAsync.when(
              data: (telemetry) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('CRUISING NAV STATE',
                            style: TextStyle(
                                color: Colors.white38,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5)),
                        const SizedBox(height: 4),
                        Text('${telemetry.speed} km/h',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w300)),
                      ],
                    ),
                    const VerticalDivider(color: Colors.white24, width: 32),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('DESTINATION CELL',
                            style: TextStyle(
                                color: Colors.cyanAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5)),
                        SizedBox(height: 4),
                        Text('NIVITHIGALA',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          )
        ],
      ),
    );
  }
}
