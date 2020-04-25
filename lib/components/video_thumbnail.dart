import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoThumbnail extends StatefulWidget {
  String videoUrl;

  VideoThumbnail(this.videoUrl);

  @override
  _VideoThumbnailState createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  VideoPlayerController _controller;

  @override
  void initState() {
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.initialized
        ? Stack(
            alignment: AlignmentDirectional.center,
            children: <Widget>[
              Container(
                color: Colors.black,
                width: double.infinity,
                height: MediaQuery.of(context).size.width *
                        (1 / _controller.value.aspectRatio) -
                    4,
              ),
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ],
          )
        : Center(child: CircularProgressIndicator());
  }
}
