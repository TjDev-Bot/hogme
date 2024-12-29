// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';


class FullScreenVideoPlayer extends StatelessWidget {
  final String videoPath;

  const FullScreenVideoPlayer({super.key, required this.videoPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: VideoPlayerWidget(videoPath: videoPath),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoPath;

  const VideoPlayerWidget({required this.videoPath, super.key});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath);
    _initializeVideoPlayerFuture = _controller.initialize();

    // Set listener for when the video ends
    _controller.addListener(() {
      if (!_controller.value.isPlaying &&
          _controller.value.position == _controller.value.duration) {
        // Video has ended
        setState(() {
          isPlaying = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isPlaying) {
            _controller.pause();
          } else {
            _controller.play();
          }
          isPlaying = !isPlaying;
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                );
              } else {
                return Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: Container(
                      color: Colors.white,
                    ),
                  ),
                );
              }
            },
          ),
          if (!isPlaying)
            const Icon(
              Icons.play_arrow,
              size: 50.0,
              color: Colors.white,
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}