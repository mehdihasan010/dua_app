import 'package:dua/core/config/dua_screen.dart';
import 'package:dua/core/di/service_locator.dart';
import 'package:dua/core/external_libs/presentable_widget_builder.dart';
import 'package:dua/core/static/ui_const.dart';
import 'package:dua/presentation/common/widgets/dua_category_card.dart';
import 'package:dua/presentation/ruqyah_video/presenter/video_play_list_presenter.dart';
import 'package:dua/presentation/ruqyah_video/widgets/featured_lecture_card.dart';
import 'package:dua/presentation/ruqyah_video/widgets/section_title.dart';
import 'package:dua/presentation/ruqyah_video/widgets/video_lecture_player.dart';
import 'package:dua/presentation/ruqyah_video/widgets/youtube_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dua/core/config/dua_custom_text_theme.dart';

class VideoPlayListPage extends StatelessWidget {
  static const _otherPlaylistTitle = 'Other Playlist';

  const VideoPlayListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final presenter = locate<VideoPlayListPresenter>();

    return PresentableWidgetBuilder<VideoPlayListPresenter>(
      presenter: presenter,
      builder: () {
        // If video is playing, use a full screen layout
        if (presenter.currentUiState.isPlayingInApp &&
            presenter.currentUiState.videoUrl != null) {
          // Set preferred orientations for video playback
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
            DeviceOrientation.portraitUp,
          ]);

          return Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: YoutubeVideoPlayer(
                videoUrl: presenter.currentUiState.videoUrl!,
                onVideoEnd: presenter.onVideoEnd,
                onBackTap: () {
                  // Restore orientation when exiting video
                  SystemChrome.setPreferredOrientations([
                    DeviceOrientation.portraitUp,
                  ]);
                  presenter.goBack();
                },
              ),
            ),
          );
        }

        // Regular layout for video browser
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                _buildVideoPlayer(presenter),
                Expanded(
                  child: _buildVideoContent(context, presenter),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideoPlayer(VideoPlayListPresenter presenter) {
    // Only show the thumbnail player when not in fullscreen mode
    return VideoLecturePlayer(
      thumbnailUrl: presenter.currentUiState.imageUrl,
      currentTime: presenter.currentUiState.currentTime,
      totalDuration: presenter.currentUiState.totalDuration,
      onPlayTap: presenter.playVideo,
      onSettingsTap: presenter.openSettings,
      onBackTap: presenter.goBack,
      videoUrl: presenter.currentUiState.videoUrl,
    );
  }

  Widget _buildVideoContent(
      BuildContext context, VideoPlayListPresenter presenter) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildVideoTitle(context, presenter),
          _buildFeaturedLectures(presenter),
          gapH14,
          _buildOtherPlaylists(presenter),
        ],
      ),
    );
  }

  Widget _buildVideoTitle(
      BuildContext context, VideoPlayListPresenter presenter) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: twentyFourPx,
        vertical: twelvePx,
      ),
      child: Text(
        presenter.currentUiState.videoTitle,
        style: Theme.of(context).extension<DuaCustomTextTheme>()?.videoTitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildFeaturedLectures(VideoPlayListPresenter presenter) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: sixteenPx),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _buildFeaturedLectureCards(presenter),
        ),
      ),
    );
  }

  List<Widget> _buildFeaturedLectureCards(VideoPlayListPresenter presenter) {
    return presenter.featuredLectures.map((lecture) {
      return Padding(
        padding: EdgeInsets.only(left: sixteenPx),
        child: GestureDetector(
          onTap: () {
            if (lecture['videoUrl'] != null) {
              presenter.setVideo(
                lecture['videoUrl']!,
                lecture['title'] ?? 'Untitled Lecture',
              );
            }
          },
          child: FeaturedLectureCard(
            thumbnailUrl: lecture['thumbnailUrl'] ?? '',
            duration: lecture['duration'] ?? '00:00:00',
            title: lecture['title'] ?? 'Untitled Lecture',
          ),
        ),
      );
    }).toList();
  }

  Widget _buildOtherPlaylists(VideoPlayListPresenter presenter) {
    return Padding(
      padding: paddingH16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: _otherPlaylistTitle),
          gapH16,
          _buildPlaylistSection(presenter),
        ],
      ),
    );
  }

  Widget _buildPlaylistSection(VideoPlayListPresenter presenter) {
    return Column(
      children: presenter.currentUiState.categories
          .map((category) => DuaCategoryCard(
                category: category,
                showDetails: false,
              ))
          .toList(),
    );
  }
}
