import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salto/providers/player_manager.dart';
import 'package:video_player/video_player.dart';

class FileVideoPlayer extends StatefulWidget {
  final bool loop;
  final File file;
  final String networkUri;

  FileVideoPlayer(this.loop, this.file, [this.networkUri = '']);

  @override
  _FileVideoPlayerState createState() => _FileVideoPlayerState();
}

class _FileVideoPlayerState extends State<FileVideoPlayer> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;
  bool _iconVisible = false;
  bool _isMute = false;

  @override
  void initState() {
    /*if (widget.networkUri.isNotEmpty) {
      _controller = VideoPlayerController.network(widget.networkUri);
    } else {
      _controller = VideoPlayerController.file(widget.file);
    }*/
    if (widget.file.path.isNotEmpty) {
      _controller = VideoPlayerController.file(widget.file);
    } else {
      _controller = VideoPlayerController.asset("assets/videos/SampleVideo_1280x720_5mb.mp4");
    }
    _controller.setLooping(widget.loop);
    _initializeVideoPlayerFuture = _controller.initialize();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerManager = Provider.of<PlayerManager>(context);
    return ConstrainedBox(
      constraints: new BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5),
      child: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                Container(
                  color: Colors.black,
                  width: double.infinity,
                  height: MediaQuery.of(context).size.width * (1 / _controller.value.aspectRatio) - 4,
                ),
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: GestureDetector(
                    onTap: () => this._toggleVideoState(),
                    child: Stack(
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          color: Colors.black,
                        ),
                        VideoPlayer(_controller),
                        Center(
                          child: AnimatedOpacity(
                            opacity: _iconVisible ? 1.0 : 0.0,
                            duration: Duration(milliseconds: 300),
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.white60,
                              child: IconButton(
                                onPressed: _toggleVideoState,
                                icon: Icon(
                                  _controller.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                ),
                              ),
                            ),
                          ),
                        ),
                        _controller.value.isPlaying ? Positioned(
                          bottom: 10,
                          right: 10,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.white60,
                            child: IconButton(
                              padding: EdgeInsets.all(0),
                              onPressed: _toggleAudioState,
                              icon: Icon(
                                _isMute
                                    ? Icons.volume_off
                                    : Icons.volume_up,
                                size: 18,
                              ),
                            ),
                          ),
                        ) : SizedBox(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  void _toggleAudioState() {
    if (_controller == null) return;
    setState(() {
      _isMute = !_isMute;
      _controller.setVolume(_isMute ? 0 : 1);
    });
  }

  void _toggleVideoState() {
    if (_controller == null) return;
    setState(() {
      _iconVisible = true;
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      Timer(Duration(seconds: 1), () {
        setState(() {
          _iconVisible = false;
        });
      });
    });
  }
}
