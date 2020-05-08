import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salto/providers/content-items.dart';
import 'package:salto/providers/storage.dart';
import 'package:video_player/video_player.dart';

class FileVideoPlayer extends StatefulWidget {
  final bool loop;
  final File file;
  final String networkUri;

  FileVideoPlayer({Key key, this.loop, this.file, this.networkUri = ''})
      : super(key: key);

  @override
  _FileVideoPlayerState createState() => _FileVideoPlayerState();
}

class _FileVideoPlayerState extends State<FileVideoPlayer> {
  File _videoFile;
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;
  bool _iconVisible = false;
  bool _isMute = false;

  @override
  void initState() {
    super.initState();
    /*_controller = VideoPlayerController.asset(
        "assets/videos/SampleVideo_1280x720_5mb.mp4");*/
    if (widget.networkUri.isEmpty) {
      _videoFile = widget.file;
      _initializeFromFile();
    } else {
      _videoFile = _getCached();
      if (_videoFile != null) {
        _initializeFromFile();
      }
    }
  }

  void _initializeFromFile() async {
    _controller = VideoPlayerController.file(_videoFile);
    _controller.setLooping(widget.loop);
    _initializeVideoPlayerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _videoFile == null
        ? FutureBuilder(
            future: _downloadVideo(widget.networkUri, context),
            builder: (context, snapshot) {
              return snapshot.connectionState == ConnectionState.done
                  ? _videoPlayerBuilder(context)
                  : Center(child: CircularProgressIndicator());
            },
          )
        : _videoPlayerBuilder(context);
  }

  Widget _videoPlayerBuilder(BuildContext context) {
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
                  height: MediaQuery.of(context).size.width *
                      (1 / _controller.value.aspectRatio) - 4,
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
                        _controller.value.isPlaying
                            ? Positioned(
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
                              )
                            : SizedBox(),
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

  Future<void> _downloadVideo(String httpPath, BuildContext ctx) async {
    final String fileName = RegExp('(-[^?/]*\.(mp4))').stringMatch(httpPath);
    _videoFile = await Provider.of<Storage>(ctx, listen: false)
        .downloadFromStorage('videos', fileName);
    _initializeFromFile();
    setState(() {});
  }

  File _getCached() {
    final String fileName = _getFileName();
    final Directory tempDir = Directory.systemTemp;
    if (File('${tempDir.path}/$fileName').existsSync()) {
      return File('${tempDir.path}/$fileName');
    }
    return null;
  }

  String _getFileName() =>
      RegExp('(-[^?/]*\.(mp4))').stringMatch(widget.networkUri);

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
