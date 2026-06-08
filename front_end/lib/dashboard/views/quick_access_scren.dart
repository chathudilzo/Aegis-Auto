import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_end/providers/media_provider.dart';
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
                    child: const ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(22),
                        bottomRight: Radius.circular(22),
                      ),
                      child: IgnorePointer(
                        child: MiniMapPreview(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildTelemetryCard(ref),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Consumer(builder: (context, ref, child) {
                    final mediaState = ref.watch(mediaProvider);
                    final currentTrack = mediaState.currentTrack;

                    return _buildCard(
                      title: 'MEDIA',
                      color: Colors.purpleAccent.withOpacity(0.1),
                      borderColor: Colors.purpleAccent,
                      icon: Icons.music_note,
                      onTap: () {
                        ref.read(mediaProvider.notifier).playTrack(TrackInfo(
                              title: "Synthwave Live Radio",
                              artist: "Nightride FM",
                              sourceUrl:
                                  "https://stream.nightride.fm/nightride.m4a",
                              sourceType: MediaSource.radio,
                            ));
                      },
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            mediaState.isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.purpleAccent)
                                : Icon(
                                    mediaState.isPlaying
                                        ? Icons.graphic_eq
                                        : Icons.album,
                                    size: 64,
                                    color: mediaState.isPlaying
                                        ? Colors.purpleAccent
                                        : Colors.white24),
                            const SizedBox(height: 16),
                            Text(
                              currentTrack?.title ?? 'No Media Selected',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              currentTrack != null
                                  ? (mediaState.isPlaying
                                      ? 'Playing • ${currentTrack.artist}'
                                      : 'Paused')
                                  : 'Tap to connect to Radio',
                              style: TextStyle(
                                  color: currentTrack != null
                                      ? Colors.purpleAccent
                                      : Colors.white54,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
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

class MiniMapPreview extends ConsumerStatefulWidget {
  const MiniMapPreview({super.key});

  @override
  ConsumerState<MiniMapPreview> createState() => _MiniMapPreviewState();
}

class _MiniMapPreviewState extends ConsumerState<MiniMapPreview>
    with OSMMixinObserver {
  late MapController _miniMapController;
  Timer? _movementTimer;
  bool _isMapInitialized = false;
  List<GeoPoint> _dynamicRoute = [];
  int _currentRouteIndex = 0;
  double _fractionalIndex = 0.0;
  GeoPoint? _currentCarPosition;

  final GeoPoint _startPoint = GeoPoint(latitude: 6.6826, longitude: 80.3992);
  final GeoPoint _endPoint = GeoPoint(latitude: 6.5958, longitude: 80.4998);

  @override
  void initState() {
    super.initState();
    _miniMapController = MapController(
      initPosition: _startPoint,
    );
    _miniMapController.addObserver(this);
  }

  @override
  Future<void> mapIsReady(bool isReady) async {
    if (isReady && !_isMapInitialized) {
      _isMapInitialized = true;
      try {
        await _miniMapController.moveTo(_startPoint, animate: false);
        await _miniMapController.setZoom(zoomLevel: 17);

        RoadInfo roadInfo = await _miniMapController.drawRoad(
          _startPoint,
          _endPoint,
          roadType: RoadType.car,
          roadOption: const RoadOption(
            roadWidth: 8,
            roadColor: Colors.blueAccent,
            zoomInto: false,
          ),
        );

        if (roadInfo.route.isNotEmpty) {
          setState(() {
            _dynamicRoute = roadInfo.route;
            _currentCarPosition = _dynamicRoute.first;
          });

          await _miniMapController.addMarker(
            _currentCarPosition!,
            markerIcon: const MarkerIcon(
              icon: Icon(
                Icons.navigation,
                color: Colors.blueAccent,
                size: 40,
              ),
            ),
            angle: 0.0,
          );

          _movementTimer?.cancel();
          _movementTimer =
              Timer.periodic(const Duration(milliseconds: 100), (timer) {
            _advanceMiniVehicle();
          });
        } else {
          debugPrint("Mini-Map Error: Route array came back empty from OSRM.");
        }
      } catch (e) {
        debugPrint("Mini-Map Init Error: $e");
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

  void _advanceMiniVehicle() async {
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

      double headingAngle = _calculateBearing(oldPosition, newPosition);

      try {
        await _miniMapController.changeLocationMarker(
          oldLocation: oldPosition,
          newLocation: newPosition,
          markerIcon: const MarkerIcon(
            icon: Icon(
              Icons.navigation,
              color: Colors.blueAccent,
              size: 40,
            ),
          ),
          angle: headingAngle,
        );

        await _miniMapController.moveTo(newPosition, animate: false);

        _currentCarPosition = newPosition;
      } catch (e) {
        debugPrint("Mini Marker Update Skip: $e");
      }
    } else if (_currentRouteIndex >= _dynamicRoute.length - 1) {
      GeoPoint endPosition = _currentCarPosition!;
      GeoPoint resetPosition = _dynamicRoute.first;

      setState(() {
        _currentRouteIndex = 0;
        _fractionalIndex = 0.0;
      });

      try {
        await _miniMapController.changeLocationMarker(
          oldLocation: endPosition,
          newLocation: resetPosition,
          markerIcon: const MarkerIcon(
            icon: Icon(
              Icons.navigation,
              color: Colors.blueAccent,
              size: 40,
            ),
          ),
          angle: 0.0,
        );
        await _miniMapController.moveTo(resetPosition, animate: false);

        _currentCarPosition = resetPosition;
      } catch (e) {
        debugPrint("Mini Reset Skip: $e");
      }
    }
  }

  @override
  void dispose() {
    _movementTimer?.cancel();
    _miniMapController.removeObserver(this);
    _miniMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OSMFlutter(
      controller: _miniMapController,
      osmOption: const OSMOption(
        showZoomController: false,
        showContributorBadgeForOSM: false,
        zoomOption: ZoomOption(
          initZoom: 17,
          minZoomLevel: 15,
          maxZoomLevel: 19,
          stepZoom: 1.0,
        ),
      ),
    );
  }
}
