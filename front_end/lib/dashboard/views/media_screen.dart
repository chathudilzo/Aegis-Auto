import 'dart:convert';
import 'package:front_end/dashboard/widgets/dashboard_grid.dart';
import 'package:siri_wave/siri_wave.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_end/dashboard/widgets/radio_tab.dart';
import 'package:front_end/providers/media_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:http/http.dart' as http;

class MediaScreen extends ConsumerStatefulWidget {
  const MediaScreen({super.key});

  @override
  ConsumerState<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends ConsumerState<MediaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _ytController = TextEditingController();
  bool _isSearchingYt = false;
  final IOS9SiriWaveformController _waveController = IOS9SiriWaveformController(
    amplitude: 0.0,
    speed: 0.0,
    color1: Colors.purpleAccent,
    color2: const Color(0xFF00D9FF),
    color3: const Color(0xFF8338EC),
  );

  final List<Map<String, String>> _radioStations = [
    {
      "title": "Synthwave Radio",
      "artist": "Nightride FM",
      "url": "https://stream.nightride.fm/nightride.m4a"
    },
    {
      "title": "Cyberpunk Industrial",
      "artist": "Darksynth FM",
      "url": "https://stream.nightride.fm/darksynth.m4a"
    },
    {
      "title": "Chillhop & Lofi",
      "artist": "Lofi Radio",
      "url": "https://stream.nightride.fm/chiptune.m4a"
    }
  ];
  var yt = YoutubeExplode();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ytController.dispose();
    super.dispose();
  }

  Future<void> _handleYoutubePlay() async {
    final rawUrl = _ytController.text.trim();
    if (rawUrl.isEmpty) return;

    setState(() => _isSearchingYt = true);

    try {
      var videoId = VideoId.parseVideoId(rawUrl);
      if (videoId == null) throw Exception("Invalid YouTube URL");

      await ref.read(mediaProvider.notifier).playTrack(
            TrackInfo(
              title: "YouTube Stream",
              artist: "YouTube",
              sourceUrl: rawUrl,
              sourceType: MediaSource.youtube,
            ),
          );
    } catch (e) {
      print("YouTube failed, searching Radio Browser API...");

      try {
        final response = await http.get(
          Uri.parse(
              "https://de1.api.radio-browser.info/json/stations/search?name=${Uri.encodeComponent(rawUrl)}&limit=1"),
        );

        if (response.statusCode == 200) {
          final List data = jsonDecode(response.body);
          if (data.isNotEmpty) {
            final station = data[0];
            ref.read(mediaProvider.notifier).playTrack(
                  TrackInfo(
                    title: station['name'],
                    artist: station['country'],
                    sourceUrl: station['url_resolved'],
                    sourceType: MediaSource.radio,
                  ),
                );
          } else {
            throw Exception("No radio matches found.");
          }
        }
      } catch (radioError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Stream unavailable and no radio match found.")),
        );
      }
    }

    setState(() {
      _isSearchingYt = false;
      _ytController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaState = ref.watch(mediaProvider);
    final currentTrack = mediaState.currentTrack;
    ref.listen<MediaState>(mediaProvider, (previous, next) {
      if (next.isPlaying) {
        _waveController.amplitude = 1.0;
        _waveController.speed = 0.20;
      } else {
        _waveController.amplitude = 0.0;
        _waveController.speed = 0.0;
      }
    });
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Row(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purpleAccent.withOpacity(0.05),
                    Colors.black,
                  ],
                ),
                border: const Border(
                    right: BorderSide(color: Colors.white12, width: 1)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF090A10),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: mediaState.isPlaying
                                  ? Colors.purpleAccent.withOpacity(0.2)
                                  : Colors.white.withOpacity(0.08),
                              width: 1.5,
                            ),
                            boxShadow: mediaState.isPlaying
                                ? [
                                    BoxShadow(
                                      color:
                                          Colors.purpleAccent.withOpacity(0.08),
                                      blurRadius: 25,
                                      spreadRadius: 1,
                                    )
                                  ]
                                : [],
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Opacity(
                                  opacity: 0.04,
                                  child: CustomPaint(
                                    painter: DashboardGridPainter(),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 16,
                                left: 20,
                                child: Row(
                                  children: [
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: mediaState.isPlaying
                                            ? Colors.purpleAccent
                                            : Colors.white24,
                                        boxShadow: mediaState.isPlaying
                                            ? [
                                                BoxShadow(
                                                    color: Colors.purpleAccent,
                                                    blurRadius: 6,
                                                    spreadRadius: 1)
                                              ]
                                            : [],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      mediaState.isPlaying
                                          ? "DSP ANALYZER ACTIVE"
                                          : "DSP STANDBY",
                                      style: const TextStyle(
                                        color: Colors.white38,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.5,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 16,
                                right: 20,
                                child: Text(
                                  "96 KHZ // 24-BIT FLAC",
                                  style: TextStyle(
                                    color: mediaState.isPlaying
                                        ? Colors.purpleAccent.withOpacity(0.5)
                                        : Colors.white24,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: SizedBox(
                                      height: 140,
                                      width: double.infinity,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(24),
                                        child: SiriWaveform.ios9(
                                          key: ValueKey(mediaState.isPlaying),
                                          controller: _waveController,
                                          options:
                                              const IOS9SiriWaveformOptions(
                                            height: 140,
                                            width: 360,
                                            showSupportBar: false,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 12,
                                left: 24,
                                right: 24,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: List.generate(5, (index) {
                                    final frequencies = [
                                      '20Hz',
                                      '250Hz',
                                      '1kHz',
                                      '4kHz',
                                      '20kHz'
                                    ];
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 1,
                                          height: 4,
                                          color: Colors.white12,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          frequencies[index],
                                          style: const TextStyle(
                                            color: Colors.white24,
                                            fontSize: 9,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (mediaState.isLoading)
                          const SizedBox(
                            height: 60,
                            width: 60,
                            child: CircularProgressIndicator(
                              color: Colors.purpleAccent,
                              strokeWidth: 3,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      currentTrack?.title ?? "SYSTEM IDLE",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      currentTrack?.artist ?? "Select an Audio Source",
                      style: const TextStyle(
                          color: Colors.purpleAccent, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.skip_previous,
                              color: Colors.white54, size: 36),
                          onPressed: () {},
                        ),
                        const SizedBox(width: 24),
                        GestureDetector(
                          onTap: currentTrack != null
                              ? () => ref
                                  .read(mediaProvider.notifier)
                                  .togglePlayPause()
                              : null,
                          child: CircleAvatar(
                            radius: 36,
                            backgroundColor: currentTrack != null
                                ? Colors.purpleAccent
                                : Colors.white12,
                            child: Icon(
                              mediaState.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          icon: const Icon(Icons.skip_next,
                              color: Colors.white54, size: 36),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 32.0, top: 48.0, right: 32.0),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicatorColor: Colors.purpleAccent,
                    labelColor: Colors.purpleAccent,
                    unselectedLabelColor: Colors.white38,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: "LIVE STREAM FM"),
                      Tab(text: "YOUTUBE CORE"),
                      Tab(text: "GLOBAL RADIO"),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      ListView.builder(
                        padding: const EdgeInsets.all(32),
                        itemCount: _radioStations.length,
                        itemBuilder: (context, index) {
                          final station = _radioStations[index];
                          final isCurrent =
                              currentTrack?.sourceUrl == station['url'];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            key: ValueKey(station['url']),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? Colors.purpleAccent.withOpacity(0.08)
                                    : Colors.white10,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isCurrent
                                      ? Colors.purpleAccent.withOpacity(0.4)
                                      : Colors.transparent,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 8),
                                leading: Icon(
                                  Icons.radio,
                                  color: isCurrent
                                      ? Colors.purpleAccent
                                      : Colors.white38,
                                ),
                                title: Text(
                                  station['title']!,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(station['artist']!,
                                    style:
                                        const TextStyle(color: Colors.white54)),
                                trailing: isCurrent && mediaState.isPlaying
                                    ? const Icon(Icons.volume_up,
                                        color: Colors.purpleAccent)
                                    : const Icon(Icons.play_arrow,
                                        color: Colors.white24),
                                onTap: () {
                                  ref.read(mediaProvider.notifier).playTrack(
                                        TrackInfo(
                                          title: station['title']!,
                                          artist: station['artist']!,
                                          sourceUrl: station['url']!,
                                          sourceType: MediaSource.radio,
                                        ),
                                      );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "STREAM DIRECT FROM URL",
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Paste any valid watch link to decouple the raw audio directly into the vehicle's amplifier system.",
                              style: TextStyle(
                                  color: Colors.white38, fontSize: 13),
                            ),
                            const SizedBox(height: 24),
                            TextField(
                              controller: _ytController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: "https://www.youtube.com/watch?v=...",
                                hintStyle:
                                    const TextStyle(color: Colors.white24),
                                filled: true,
                                fillColor: Colors.white12,
                                prefixIcon: const Icon(Icons.link,
                                    color: Colors.purpleAccent),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                      color: Colors.purpleAccent),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purpleAccent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                ),
                                onPressed:
                                    _isSearchingYt ? null : _handleYoutubePlay,
                                child: _isSearchingYt
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.bolt, color: Colors.white),
                                          SizedBox(width: 8),
                                          Text(
                                            "EXTRACT & INJECT AUDIO",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const GlobalRadioDiscoveryTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
