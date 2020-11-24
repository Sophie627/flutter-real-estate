import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FullScreenVideoViewer extends StatefulWidget {
  final String videoUrl;
  final String heroTag;

  const FullScreenVideoViewer(
      {Key key, @required this.videoUrl, @required this.heroTag})
      : super(key: key);

  @override
  _FullScreenVideoViewerState createState() =>
      _FullScreenVideoViewerState(videoUrl, heroTag);
}

class _FullScreenVideoViewerState extends State<FullScreenVideoViewer> {
  VideoPlayerController _controller;
  final String videoUrl;
  final String heroTag;

  _FullScreenVideoViewerState(this.videoUrl, this.heroTag);

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(videoUrl)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        elevation: 0.0,
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
          color: Colors.black,
          child: Hero(
            tag: videoUrl,
            child: Center(
              child: _controller.value.initialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : Container(),
            ),
          )),
      floatingActionButton: FloatingActionButton(
        heroTag: heroTag,
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
