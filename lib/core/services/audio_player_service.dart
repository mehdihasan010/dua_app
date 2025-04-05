import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  ValueNotifier<bool> isPlaying = ValueNotifier<bool>(false);
  ValueNotifier<Duration> position = ValueNotifier<Duration>(Duration.zero);
  ValueNotifier<Duration> totalDuration =
      ValueNotifier<Duration>(Duration.zero);

  // For demonstration, map audio IDs to reliable sample audio URLs
  final Map<int, String> _sampleAudioUrls = {
    1: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
    2: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
    3: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
    4: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
    5: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
  };

  AudioPlayerService() {
    _setupListeners();
  }

  void _setupListeners() {
    _audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
    });

    _audioPlayer.positionStream.listen((pos) {
      position.value = pos;
    });

    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        totalDuration.value = duration;
      }
    });

    // Listen for errors
    _audioPlayer.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace st) {
      if (kDebugMode) {
        print('Player error: $e');
      }
    });
  }

  Future<void> playAudio(int audioId) async {
    try {
      await _audioPlayer.stop();

      // Get a sample URL based on the audio ID
      // For demonstration, using a set of reliable sample URLs
      final audioUrl =
          _sampleAudioUrls[audioId % _sampleAudioUrls.length + 1] ??
              'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';

      if (kDebugMode) {
        print('Playing audio from URL: $audioUrl');
      }

      // Use setAudioSource with ProgressiveAudioSource for better buffering
      await _audioPlayer.setAudioSource(
        ProgressiveAudioSource(Uri.parse(audioUrl)),
      );
      await _audioPlayer.play();
    } catch (e) {
      if (kDebugMode) {
        print('Error playing audio: $e');
      }

      // Try fallback URL if the first one fails
      try {
        await _audioPlayer.stop();
        await _audioPlayer.setAudioSource(
          ProgressiveAudioSource(Uri.parse(
              'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3')),
        );
        await _audioPlayer.play();
      } catch (fallbackError) {
        if (kDebugMode) {
          print('Fallback audio also failed: $fallbackError');
        }
      }
    }
  }

  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
  }

  Future<void> resumeAudio() async {
    await _audioPlayer.play();
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
  }

  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  void dispose() {
    _audioPlayer.dispose();
    isPlaying.dispose();
    position.dispose();
    totalDuration.dispose();
  }
}
