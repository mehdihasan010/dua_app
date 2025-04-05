import 'package:dua/core/di/service_locator.dart';
import 'package:dua/core/services/audio_player_service.dart';
import 'package:dua/core/services/bookmark_service.dart';
import 'package:dua/domain/entities/dua.dart';
import 'package:flutter/material.dart';

class DuaDetailsPage extends StatefulWidget {
  final DuaEntity dua;

  const DuaDetailsPage({super.key, required this.dua});

  @override
  State<DuaDetailsPage> createState() => _DuaDetailsPageState();
}

class _DuaDetailsPageState extends State<DuaDetailsPage> {
  late final AudioPlayerService _audioPlayerService;
  late final BookmarkService _bookmarkService;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _audioPlayerService = locate<AudioPlayerService>();
    _bookmarkService = locate<BookmarkService>();
    _isBookmarked = _bookmarkService.isDuaBookmarked(widget.dua.id);
  }

  @override
  void dispose() {
    // We don't dispose the service since it's a singleton,
    // but we stop playback when leaving the page
    _audioPlayerService.stopAudio();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_audioPlayerService.isPlaying.value) {
      _audioPlayerService.pauseAudio();
    } else {
      if (widget.dua.audio != 0) {
        _audioPlayerService.playAudio(widget.dua.audio);
      }
    }
  }

  void _toggleBookmark() async {
    await _bookmarkService.toggleBookmark(widget.dua);
    setState(() {
      _isBookmarked = _bookmarkService.isDuaBookmarked(widget.dua.id);
    });

    // Show snackbar to confirm the action
    final String message =
        _isBookmarked ? 'Dua added to bookmarks' : 'Dua removed from bookmarks';

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dua.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: _isBookmarked ? Colors.amber : null,
            ),
            onPressed: _toggleBookmark,
            tooltip: 'Bookmark',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.dua.indopak.isNotEmpty) ...[
              const SizedBox(height: 8.0),
              Text(
                widget.dua.indopak,
                style: const TextStyle(
                  fontFamily: 'KFGQ',
                  fontSize: 28,
                  height: 2.0,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
            if (widget.dua.transliteration.isNotEmpty) ...[
              const SizedBox(height: 16.0),
              Text(
                widget.dua.transliteration,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
              ),
            ],
            if (widget.dua.translation.isNotEmpty) ...[
              const SizedBox(height: 16.0),
              Text(
                widget.dua.translation,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
              ),
            ],
            if (widget.dua.reference.isNotEmpty) ...[
              const SizedBox(height: 24.0),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  widget.dua.reference,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
            if (widget.dua.audio != 0) ...[
              const SizedBox(height: 24.0),
              _buildAudioPlayer(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAudioPlayer() {
    return Column(
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: _audioPlayerService.isPlaying,
          builder: (context, isPlaying, child) {
            return FilledButton.icon(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              label: Text(isPlaying ? 'Pause Audio' : 'Play Audio'),
              onPressed: _togglePlayPause,
            );
          },
        ),
        const SizedBox(height: 16.0),
        ValueListenableBuilder<Duration>(
          valueListenable: _audioPlayerService.position,
          builder: (context, position, _) {
            return ValueListenableBuilder<Duration>(
              valueListenable: _audioPlayerService.totalDuration,
              builder: (context, totalDuration, _) {
                // Ensure position never exceeds total duration to prevent slider errors
                final safeDuration = totalDuration.inMilliseconds > 0
                    ? totalDuration
                    : const Duration(milliseconds: 1);
                final safePosition =
                    position.inMilliseconds <= safeDuration.inMilliseconds
                        ? position
                        : safeDuration;
                return Column(
                  children: [
                    Slider(
                      value: safePosition.inMilliseconds.toDouble(),
                      min: 0,
                      max: safeDuration.inMilliseconds.toDouble(),
                      onChanged: (value) {
                        _audioPlayerService.seekTo(
                          Duration(milliseconds: value.toInt()),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(safePosition)),
                          Text(_formatDuration(safeDuration)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
