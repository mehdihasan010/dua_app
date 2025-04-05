import 'package:dua/core/base/base_presenter.dart';
import 'package:dua/core/config/app_images.dart';
import 'package:dua/core/extensions/context_extension.dart';
import 'package:dua/core/utility/utility.dart';
import 'package:dua/presentation/ruqyah_video/presenter/video_play_list_ui_state.dart';
import 'package:flutter/material.dart';

class VideoPlayListPresenter extends BasePresenter<VideoPlayListUiState> {
  VideoPlayListPresenter();

  final Obs<VideoPlayListUiState> uiState = Obs(VideoPlayListUiState.empty());

  VideoPlayListUiState get currentUiState => uiState.value;

  // Sample YouTube video URLs for Islamic content
  final List<String> _islamicVideoUrls = [
    'https://www.youtube.com/watch?v=kwmeoSBliDo',
    'https://www.youtube.com/watch?v=kwmeoSBliDo',
    'https://www.youtube.com/watch?v=kwmeoSBliDo',
    'https://www.youtube.com/watch?v=kwmeoSBliDo',
  ];

  void playVideo() async {
    try {
      // Get current or random video URL
      String videoUrl = currentUiState.videoUrl ?? _getRandomVideoUrl();

      if (videoUrl.isEmpty) {
        showMessage(message: 'Invalid video URL');
        return;
      }

      // Update UI state to show the video is playing in-app
      uiState.value = currentUiState.copyWith(
        isPlayingInApp: true,
        videoUrl: videoUrl,
      );
    } catch (e) {
      debugPrint('Error playing video: $e');
      showMessage(message: 'Error playing video');
    }
  }

  String _getRandomVideoUrl() {
    // Get a random index
    final random = _islamicVideoUrls[
        DateTime.now().microsecond % _islamicVideoUrls.length];
    return random;
  }

  void setVideoUrl(String url) {
    uiState.value = currentUiState.copyWith(videoUrl: url);
  }

  // Set video title and URL at the same time for better UX
  void setVideo(String url, String title) {
    uiState.value = currentUiState.copyWith(
      videoUrl: url,
      videoTitle: title,
    );
  }

  void openSettings() {
    // Handle settings button tap
    showMessage(message: 'Settings not implemented');
  }

  void goBack() {
    // Before popping, make sure to stop any playing video
    if (currentUiState.isPlayingInApp) {
      uiState.value = currentUiState.copyWith(isPlayingInApp: false);
    } else {
      // Use safe context extension to navigate back safely
      ContextExtension.safePop(null);
    }
  }

  void onVideoEnd() {
    // Set playing state to false when video ends
    uiState.value = currentUiState.copyWith(isPlayingInApp: false);
  }

  List<Map<String, String>> get featuredLectures => [
        {
          'thumbnailUrl': AppImages.videoThumbnail3,
          'duration': '00:43:59',
          'title': 'PROPHET (ﷺ) WARNED EVERY MUSLIM OF 2 WOLVES',
          'videoUrl': _islamicVideoUrls[0],
        },
        {
          'thumbnailUrl': AppImages.videoThumbnail2,
          'duration': '00:43:59',
          'title':
              'THIS LECTURE IS CAPABLE OF CHANGING ANY MUSLIM - MOHAMMAD HOBLOS',
          'videoUrl': _islamicVideoUrls[1],
        },
        {
          'thumbnailUrl': AppImages.videoThumbnail4,
          'duration': '00:43:59',
          'title': 'PROPHET (ﷺ) WARNED EVERY MUSLIM OF 2 WOLVES',
          'videoUrl': _islamicVideoUrls[2],
        },
        {
          'thumbnailUrl': AppImages.videoThumbnail2,
          'duration': '00:43:59',
          'title':
              'THIS LECTURE IS CAPABLE OF CHANGING ANY MUSLIM - MOHAMMAD HOBLOS',
          'videoUrl': _islamicVideoUrls[3],
        },
      ];

  @override
  Future<void> addUserMessage(String message) {
    return showMessage(message: message);
  }

  @override
  Future<void> toggleLoading({required bool loading}) async {
    uiState.value = currentUiState.copyWith(isLoading: loading);
  }
}
