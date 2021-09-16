import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

void main() => runApp(const VideoPlayerApp());

class VideoPlayerApp extends StatelessWidget {
  const VideoPlayerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Video Player Demo',
      home: VideoPlayerScreen(),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({Key? key}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  static String? _getIdFromUrl(String url, [bool trimWhitespaces = true]) {
    List<RegExp> _regexps = [
      RegExp(
          r'^https:\/\/(?:www\.|m\.)?youtube\.com\/watch\?v=([_\-a-zA-Z0-9]{11}).*$'),
      RegExp(
          r'^https:\/\/(?:www\.|m\.)?youtube(?:-nocookie)?\.com\/embed\/([_\-a-zA-Z0-9]{11}).*$'),
      RegExp(r'^https:\/\/youtu\.be\/([_\-a-zA-Z0-9]{11}).*$')
    ];

    if (url.isEmpty) {
      return null;
    }

    if (trimWhitespaces) {
      url = url.trim();
    }

    for (RegExp exp in _regexps) {
      final RegExpMatch? match = exp.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }
    }

    return null;
  }

  @override
  void initState() {
    super.initState();

    () async {

      var videoId = _getIdFromUrl("https://www.youtube.com/watch?v=fwvSRXQ-iDo");

      var yt = YoutubeExplode();

      var manifest = await yt.videos.streamsClient.getManifest(videoId);

      Uri? videoUri;
      manifest.muxed.forEach((m) {
        if (VideoQuality.high720 == m.videoQuality) {
          videoUri = m.url;
        }
      });

      String finalYoutubeUrl = "";
      if (videoUri == null) {
        finalYoutubeUrl = manifest.muxed.first.url.toString();
      } else {
        finalYoutubeUrl = videoUri.toString();
      }
      // Create and store the VideoPlayerController. The VideoPlayerController
      // offers several different constructors to play videos from assets, files,
      // or the internet.
      _controller = VideoPlayerController.network(
        finalYoutubeUrl,
      );

      // Initialize the controller and store the Future for later use.
      _initializeVideoPlayerFuture = _controller.initialize();

      // Use the controller to loop the video.
      _controller.setLooping(true);

      setState(() {
        // Update your UI with the desired changes.
      });
    }();


  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Butterfly Video'),
      ),
      // Use a FutureBuilder to display a loading spinner while waiting for the
      // VideoPlayerController to finish initializing.
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the VideoPlayerController has finished initialization, use
            // the data it provides to limit the aspect ratio of the video.
            return AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              // Use the VideoPlayer widget to display the video.
              child: VideoPlayer(_controller),
            );
          } else {
            // If the VideoPlayerController is still initializing, show a
            // loading spinner.
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Wrap the play or pause in a call to `setState`. This ensures the
          // correct icon is shown.
          setState(() {
            // If the video is playing, pause it.
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              // If the video is paused, play it.
              _controller.play();
            }
          });
        },
        // Display the correct icon depending on the state of the player.
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
