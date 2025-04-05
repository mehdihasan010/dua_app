import 'package:dua/presentation/ruqyah_video/widgets/duration_display.dart';
import 'package:dua/presentation/ruqyah_video/widgets/video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:dua/core/config/app_images.dart';
import 'package:dua/core/static/ui_const.dart';
import 'package:dua/core/utility/utility.dart';
import 'package:dua/core/config/video_player_styles.dart';
import 'package:dua/presentation/ruqyah_video/widgets/video_control_button.dart';
import 'package:video_player/video_player.dart';

class VideoLecturePlayer extends StatefulWidget {
  const VideoLecturePlayer({
    super.key,
    required this.thumbnailUrl,
    required this.currentTime,
    required this.totalDuration,
    this.onPlayTap,
    this.onSettingsTap,
    this.onBackTap,
    this.videoUrl,
  });

  final String thumbnailUrl;
  final String currentTime;
  final String totalDuration;
  final VoidCallback? onPlayTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onBackTap;
  final String? videoUrl;

  @override
  State<VideoLecturePlayer> createState() => _VideoLecturePlayerState();
}

class _VideoLecturePlayerState extends State<VideoLecturePlayer> {
  VideoPlayerController? _controller;
  bool _isPlaying = false;
  bool _isInitialized = false;
  String _currentPosition = '00:00:00';

  @override
  void initState() {
    super.initState();
    if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      _initializeVideoPlayer(widget.videoUrl!);
    }
  }

  void _initializeVideoPlayer(String url) {
    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _setupVideoListener();
      });
  }

  void _setupVideoListener() {
    _controller?.addListener(() {
      if (_controller!.value.isPlaying != _isPlaying) {
        setState(() {
          _isPlaying = _controller!.value.isPlaying;
        });
      }

      final position = _controller!.value.position;
      setState(() {
        _currentPosition = _formatDuration(position);
      });
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  void _playPauseVideo() {
    if (_controller == null || !_isInitialized) {
      if (widget.onPlayTap != null) {
        widget.onPlayTap!();
      }
      return;
    }

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: VideoPlayerStyles.playerHeight,
          child: Stack(
            children: [
              _isInitialized && _controller != null
                  ? AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    )
                  : _buildThumbnail(context),
              _buildControlsOverlay(context),
            ],
          ),
        ),
        _isInitialized && _controller != null
            ? VideoProgressBar(
                progress: _controller!.value.position.inMilliseconds /
                    (_controller!.value.duration.inMilliseconds == 0
                        ? 1
                        : _controller!.value.duration.inMilliseconds),
              )
            : const VideoProgressBar(),
      ],
    );
  }

  Widget _buildThumbnail(BuildContext context) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.color.black,
          image: DecorationImage(
            image: AssetImage(widget.thumbnailUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              context.color.black
                  .withOpacityInt(VideoPlayerStyles.overlayOpacity),
              BlendMode.darken,
            ),
          ),
        ),
      );

  Widget _buildControlsOverlay(BuildContext context) => Positioned.fill(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopControls(),
            _buildPlayControls(),
            DurationDisplay(
              currentTime:
                  _isInitialized ? _currentPosition : widget.currentTime,
              totalDuration: _isInitialized && _controller != null
                  ? _formatDuration(_controller!.value.duration)
                  : widget.totalDuration,
            ),
          ],
        ),
      );

  Widget _buildTopControls() => Padding(
        padding: VideoPlayerStyles.controlsPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            VideoControlButton(
              icon: AppImages.icArrowDown,
              onPressed: widget.onBackTap,
            ),
            VideoControlButton(
              icon: AppImages.icSetting2,
              onPressed: widget.onSettingsTap,
            ),
          ],
        ),
      );

  Widget _buildPlayControls() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          VideoControlButton(
            icon: AppImages.icPrevious,
            onPressed: () {
              if (_controller != null && _isInitialized) {
                final newPosition =
                    _controller!.value.position - const Duration(seconds: 10);
                _controller!.seekTo(
                    newPosition.isNegative ? Duration.zero : newPosition);
              }
            },
          ),
          gapW40,
          VideoControlButton(
            icon: _isPlaying ? AppImages.icNext : AppImages.icPlay,
            onPressed: _playPauseVideo,
            isPlayButton: true,
          ),
          gapW40,
          VideoControlButton(
            icon: AppImages.icNext,
            onPressed: () {
              if (_controller != null && _isInitialized) {
                final newPosition =
                    _controller!.value.position + const Duration(seconds: 10);
                final maxDuration = _controller!.value.duration;
                _controller!.seekTo(
                    newPosition > maxDuration ? maxDuration : newPosition);
              }
            },
          ),
        ],
      );
}
