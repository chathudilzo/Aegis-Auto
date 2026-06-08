import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_my_radio/objects/my_radio_tools.dart';

enum MediaSource { bundled, radio, youtube }

class TrackInfo {
  final String title;
  final String artist;
  final String sourceUrl;
  final MediaSource sourceType;
  final String? coverArtUrl;
  final String? stationUuid;

  TrackInfo({
    required this.title,
    required this.artist,
    required this.sourceUrl,
    required this.sourceType,
    this.coverArtUrl,
    this.stationUuid,
  });
}

class MediaState {
  final TrackInfo? currentTrack;
  final bool isPlaying;
  final bool isLoading;
  final Duration position;
  final Duration duration;

  MediaState({
    this.currentTrack,
    this.isPlaying = false,
    this.isLoading = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  MediaState copyWith({
    TrackInfo? currentTrack,
    bool? isPlaying,
    bool? isLoading,
    Duration? position,
    Duration? duration,
  }) {
    return MediaState(
      currentTrack: currentTrack ?? this.currentTrack,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}

class MediaNotifier extends StateNotifier<MediaState> {
  MediaNotifier() : super(MediaState()) {
    _initAudioPlayer();
    _initRadioTools();
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  final MyRadioTools _radioTools = MyRadioTools();
  final String _pipedApi = "https://pipedapi.kavin.rocks";

  void _initAudioPlayer() {
    _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;

      state = state.copyWith(
        isPlaying: isPlaying,
        isLoading: processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering,
      );
    });

    _audioPlayer.positionStream.listen((position) {
      state = state.copyWith(position: position);
    });

    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        state = state.copyWith(duration: duration);
      }
    });
  }

  void _initRadioTools() {
    _radioTools.updateRadioBrowserApiUrls();
  }

  Future<void> playTrack(TrackInfo track) async {
    state = state.copyWith(currentTrack: track, isLoading: true);

    try {
      String finalPlayableUrl = track.sourceUrl;

      if (track.sourceType == MediaSource.youtube) {
        final regExp = RegExp(r'(?:v=|be/|embed/|youtu\.be/)([\w-]+)');
        final match = regExp.firstMatch(track.sourceUrl);

        if (match == null) throw Exception("Could not parse Video ID");
        final videoId = match.group(1)!;

        final response =
            await http.get(Uri.parse("$_pipedApi/streams/$videoId"));

        if (response.statusCode != 200) {
          throw Exception("Piped API Error: ${response.statusCode}");
        }

        final data = jsonDecode(response.body);
        final List audioStreams = data['audioStreams'];

        if (audioStreams.isEmpty) throw Exception("No audio streams found");

        final stream = audioStreams.firstWhere(
          (s) => s['codec'] == 'm4a',
          orElse: () => audioStreams.first,
        );

        finalPlayableUrl = stream['url'];
        print("DEBUG: Secure Piped Proxy URL: $finalPlayableUrl");
      }
      if (track.sourceType == MediaSource.radio && track.stationUuid != null) {
        _radioTools.addClick(track.stationUuid!);
      }
      if (track.sourceType == MediaSource.bundled) {
        await _audioPlayer.setAsset(finalPlayableUrl);
      } else {
        await _audioPlayer.setAudioSource(
          AudioSource.uri(
            Uri.parse(finalPlayableUrl),
            headers: {
              "User-Agent":
                  "Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Mobile Safari/537.36"
            },
          ),
        );
      }

      await _audioPlayer.play();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      print("CRITICAL ENGINE ERROR: $e");
      state = state.copyWith(isLoading: false);
    }
  }

  void togglePlayPause() {
    if (_audioPlayer.playing) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

final mediaProvider = StateNotifierProvider<MediaNotifier, MediaState>((ref) {
  return MediaNotifier();
});
