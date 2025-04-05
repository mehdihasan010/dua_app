import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class YoutubeVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final VoidCallback? onVideoEnd;
  final VoidCallback? onBackTap;

  const YoutubeVideoPlayer({
    super.key,
    required this.videoUrl,
    this.onVideoEnd,
    this.onBackTap,
  });

  @override
  State<YoutubeVideoPlayer> createState() => _YoutubeVideoPlayerState();
}

class _YoutubeVideoPlayerState extends State<YoutubeVideoPlayer> {
  late InAppWebViewController _webViewController;
  late String _videoId;
  bool _isLoading = true;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _videoId = _extractVideoId(widget.videoUrl);
  }

  String _extractVideoId(String url) {
    String videoId = 'kwmeoSBliDo'; // Default fallback ID

    try {
      if (url.contains('youtube.com/watch')) {
        final uri = Uri.parse(url);
        final extractedId = uri.queryParameters['v'];
        if (extractedId != null && extractedId.isNotEmpty) {
          videoId = extractedId;
        }
      } else if (url.contains('youtu.be/')) {
        final uri = Uri.parse(url);
        final segments = uri.pathSegments;
        if (segments.isNotEmpty) {
          videoId = segments.last;
        }
      }
    } catch (e) {
      debugPrint('Error extracting YouTube video ID: $e');
    }

    return videoId;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Controls bar
        Container(
          color: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: widget.onBackTap,
              ),
              const Spacer(),
              if (_isLoading)
                Text(
                  'Loading ${(_progress * 100).toInt()}%',
                  style: const TextStyle(color: Colors.white),
                ),
            ],
          ),
        ),

        // Progress indicator
        if (_isLoading) LinearProgressIndicator(value: _progress),

        // WebView
        Expanded(
          child: Stack(
            children: [
              InAppWebView(
                initialUrlRequest: URLRequest(
                  url: WebUri("https://www.youtube.com/embed/$_videoId"),
                ),
                initialSettings: InAppWebViewSettings(
                  mediaPlaybackRequiresUserGesture: false,
                  allowsInlineMediaPlayback: true,
                  iframeAllowFullscreen: true,
                ),
                onWebViewCreated: (controller) {
                  _webViewController = controller;
                },
                onLoadStart: (controller, url) {
                  setState(() {
                    _isLoading = true;
                  });
                },
                onProgressChanged: (controller, progress) {
                  setState(() {
                    _progress = progress / 100;
                  });
                },
                onLoadStop: (controller, url) {
                  setState(() {
                    _isLoading = false;
                  });

                  // Add JavaScript event listener for video ended
                  _webViewController.addJavaScriptHandler(
                    handlerName: 'videoEnded',
                    callback: (args) {
                      if (widget.onVideoEnd != null) {
                        widget.onVideoEnd!();
                      }
                      return null;
                    },
                  );

                  // Inject JavaScript to listen for video end event
                  _injectVideoEndListener();
                },
                onConsoleMessage: (controller, consoleMessage) {
                  debugPrint("Console: ${consoleMessage.message}");
                },
                onReceivedError: (controller, request, error) {
                  debugPrint("WebView Error: ${error.description}");
                  setState(() {
                    _isLoading = false;
                  });
                },
              ),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _injectVideoEndListener() {
    final js = '''
    // Try to access the player when it's ready
    function checkYouTubePlayerAPI() {
      if (document.querySelector('iframe') && document.querySelector('iframe').contentWindow) {
        try {
          const player = document.querySelector('iframe').contentWindow;
          
          // Listen for messages from the iframe
          window.addEventListener('message', function(event) {
            // Check if the message is from YouTube
            if (event.origin.startsWith('https://www.youtube.com')) {
              const data = JSON.parse(event.data);
              // Check if it's the onStateChange event and the state is 0 (ended)
              if (data.event === 'onStateChange' && data.info === 0) {
                // Call our handler when video ends
                window.flutter_inappwebview.callHandler('videoEnded');
              }
            }
          });
          
          return true;
        } catch (e) {
          console.log('Error accessing YouTube player:', e);
          return false;
        }
      }
      return false;
    }
    
    // Check immediately and then try again in case the player isn't ready yet
    if (!checkYouTubePlayerAPI()) {
      setTimeout(checkYouTubePlayerAPI, 1000);
    }
    ''';

    _webViewController.evaluateJavascript(source: js);
  }
}
