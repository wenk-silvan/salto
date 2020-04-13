import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FileVideoPlayer extends StatefulWidget {
  final bool autoplay;
  final File file;
  final String networkUri;
  FileVideoPlayer(this.autoplay, this.file, [this.networkUri = '']);

  @override
  _FileVideoPlayerState createState() => _FileVideoPlayerState();
}

class _FileVideoPlayerState extends State<FileVideoPlayer> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    if (widget.networkUri.isNotEmpty) {
      _controller = VideoPlayerController.network(widget.networkUri);
    }
    else {
      _controller = VideoPlayerController.file(widget.file);
    }
    _controller.setLooping(widget.autoplay);
    _initializeVideoPlayerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleVideoState() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: GestureDetector(
                onTap: () => this._toggleVideoState(),
                child: Stack(
                  children: <Widget>[
                    VideoPlayer(_controller),
                    Center(
                      child: FloatingActionButton(
                        onPressed: () => this._toggleVideoState(),
                        backgroundColor: Colors.white38,
                        child: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
