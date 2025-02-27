import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_video_thumbnail_plus/flutter_video_thumbnail_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class VideoThumbnailWidget extends StatefulWidget {
  final String videoUrl;

  const VideoThumbnailWidget({super.key, required this.videoUrl});

  @override
  State<VideoThumbnailWidget> createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  String? _thumbnailPath;

  @override
  void initState() {
    super.initState();
    _getOrGenerateThumbnail(widget.videoUrl);
  }

  Future<void> _getOrGenerateThumbnail(String videoUrl) async {
    final tempDir = await getTemporaryDirectory();
    final thumbnailFileName =
        'thumbnail_${Uri.parse(videoUrl).pathSegments.last}.png';
    final thumbnailFilePath = '${tempDir.path}/$thumbnailFileName';
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        if (await File(thumbnailFilePath).exists()) {
          setState(() {
            _thumbnailPath = thumbnailFilePath;
          });
        } else {
          final newThumbnailPath =
              await FlutterVideoThumbnailPlus.thumbnailFile(
            video: videoUrl,
            thumbnailPath: thumbnailFilePath,
            imageFormat: ImageFormat.png,
            maxWidth: 128,
            quality: 75,
          );
          setState(() {
            _thumbnailPath = newThumbnailPath;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _thumbnailPath != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(_thumbnailPath!),
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
            ),
          )
        : CircularProgressIndicator();
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : CircularProgressIndicator();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
