import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_end/providers/media_provider.dart';
import 'package:http/http.dart' as http;

class GlobalRadioDiscoveryTab extends ConsumerStatefulWidget {
  const GlobalRadioDiscoveryTab({super.key});

  @override
  ConsumerState<GlobalRadioDiscoveryTab> createState() =>
      _GlobalRadioDiscoveryTabState();
}

class _GlobalRadioDiscoveryTabState
    extends ConsumerState<GlobalRadioDiscoveryTab> {
  final _searchController = TextEditingController();
  List<dynamic> _radioStations = [];
  bool _isLoading = false;
  String _errorMessage = "";

  final List<String> _quickTags = [
    "Top 50",
    "Sri Lanka",
    "Synthwave",
    "Lofi",
    "News",
    "Pop",
    "Rock",
    "Jazz"
  ];
  String _selectedTag = "Top 50";

  @override
  void initState() {
    super.initState();
    _loadCategory("Top 50");
  }

  Future<void> _loadCategory(String tag) async {
    setState(() {
      _selectedTag = tag;
      _isLoading = true;
      _errorMessage = "";
      _searchController.clear();
    });

    try {
      Uri url;
      if (tag == "Top 50") {
        url = Uri.parse(
            'https://de1.api.radio-browser.info/json/stations/topclick/50?hidebroken=true');
      } else {
        url = Uri.parse(
            'https://de1.api.radio-browser.info/json/stations/bytag/${Uri.encodeComponent(tag.toLowerCase())}?limit=30&hidebroken=true&order=clickcount&reverse=true');
      }

      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _radioStations = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception("Server Error");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Connection lost. Unable to load directory.";
      });
    }
  }

  Future<void> _searchManual(String query) async {
    if (query.isEmpty) return;
    setState(() {
      _selectedTag = "";
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      final url = Uri.parse(
          'https://de1.api.radio-browser.info/json/stations/search?name=${Uri.encodeComponent(query)}&limit=20&hidebroken=true&order=clickcount&reverse=true');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _radioStations = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Search failed.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SizedBox(
            height: 50,
            child: SearchBar(
              leading: const Icon(Icons.search, color: Colors.purpleAccent),
              controller: _searchController,
              hintText: "Search specific station...",
              onSubmitted: (value) => _searchManual(value),
              trailing: [
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => _searchManual(_searchController.text),
                )
              ],
            ),
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _quickTags.length,
            itemBuilder: (context, index) {
              final tag = _quickTags[index];
              final isSelected = _selectedTag == tag;

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(tag,
                      style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold)),
                  selected: isSelected,
                  selectedColor: Colors.purpleAccent,
                  backgroundColor: Colors.white12,
                  showCheckmark: false,
                  onSelected: (selected) {
                    if (selected) _loadCategory(tag);
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        if (_isLoading)
          const Expanded(
              child: Center(
                  child:
                      CircularProgressIndicator(color: Colors.purpleAccent))),
        if (_errorMessage.isNotEmpty)
          Expanded(
              child: Center(
                  child: Text(_errorMessage,
                      style: const TextStyle(color: Colors.red)))),
        if (!_isLoading && _errorMessage.isEmpty)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _radioStations.length,
              itemBuilder: (context, index) {
                final station = _radioStations[index];

                final String name = station['name'] ?? "Unknown Station";
                final String tags = station['tags'] ?? "Live Broadcast";
                final String streamUrl =
                    station['url_resolved'] ?? station['url'] ?? "";
                final String favicon = station['favicon'] ?? "";

                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  leading: favicon.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            favicon,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.radio,
                                color: Colors.white24,
                                size: 48),
                          ),
                        )
                      : const Icon(Icons.radio,
                          color: Colors.white24, size: 48),
                  title: Text(name.trim(),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  subtitle: Text(tags,
                      style: const TextStyle(color: Colors.purpleAccent),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  trailing: const Icon(Icons.play_circle_fill,
                      color: Colors.purpleAccent, size: 36),
                  onTap: () {
                    if (streamUrl.isEmpty) return;
                    ref.read(mediaProvider.notifier).playTrack(TrackInfo(
                          title: name.trim(),
                          artist: tags.split(',').first.toUpperCase(),
                          sourceUrl: streamUrl,
                          sourceType: MediaSource.radio,
                          coverArtUrl: favicon.isNotEmpty ? favicon : null,
                        ));
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
