import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:salto/providers/auth.dart';
import 'package:salto/screens/splash_screen.dart';
import 'package:salto/screens/upload_screen.dart';
import 'package:sensors/sensors.dart';

class CameraScreen extends StatefulWidget {
  static const route = '/camera';
  final List<CameraDescription> cameras;

  const CameraScreen({
    Key key,
    @required this.cameras,
  }) : super(key: key);

  void logError(String code, String message) =>
      print('Error: $code\nError Message: $message');

  IconData getCameraLensIcon(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.back:
        return Icons.camera_rear;
      case CameraLensDirection.front:
        return Icons.camera_front;
      case CameraLensDirection.external:
        return Icons.camera;
    }
    throw ArgumentError('Unknown lens direction');
  }

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  Future<void> _initializeControllerFuture;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  CameraController _controller;
  DeviceOrientation _orientation;
  bool _rotationMessageShown = false;
  String _videoPath;
  Timer _timer;
  int _recordingTime;
  String _timerString;

  @override
  void initState() {
    super.initState();
    var running = false;
    accelerometerEvents.listen((AccelerometerEvent event) {
      if (running || _controller.value.isRecordingVideo ||
          _controller.value.isRecordingPaused) return;
      running = true;
      Timer(Duration(milliseconds: 500), () {
        running = false;
        DeviceOrientation orientation;
        orientation = DeviceOrientation.portraitUp;
        if (event.y <= 5) {
          if (event.x > 3) {
            orientation = DeviceOrientation.landscapeLeft;
            _rotationMessageShown = false;
          }
          else if (event.x < -3) {
            orientation = DeviceOrientation.portraitUp;
            if (!_rotationMessageShown) {
              _showInSnackBar("Please rotate device.");
              _rotationMessageShown = true;
            }
          }
        }
        if (_orientation != orientation) {
          setState(() {
            _orientation = orientation;
          });
        }
      });
    });

    if (widget.cameras.isEmpty) {
      return;
    }
    _timerString = "";
    _controller = CameraController(
      widget.cameras
          .firstWhere((cam) => cam.lensDirection == CameraLensDirection.back),
      ResolutionPreset.medium,
      enableAudio: true,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!Provider.of<Auth>(context).isAuth) {
      Navigator.of(context).pop();
      return SplashScreen();
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Record Video'),
        actions: <Widget>[
          IconButton(
            icon: _rotatedWidgetBuilder(Icon(
                this._controller.description.lensDirection ==
                        CameraLensDirection.back
                    ? Icons.camera_front
                    : Icons.camera_rear)),
            onPressed: () =>
                this._switchCamera(this._controller.description.lensDirection),
          ),
          IconButton(
            icon: _rotatedWidgetBuilder(Icon(Icons.aspect_ratio)),
            onPressed:
                _controller != null && !_controller.value.isRecordingVideo
                    ? _changeAspectRatio
                    : null,
          ),
          SizedBox(width: 20),
        ],
      ),
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: <Widget>[
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Center(child: _cameraPreviewWidget()),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(
                      color: _controller != null &&
                              _controller.value.isRecordingVideo
                          ? Colors.redAccent
                          : Colors.grey,
                      width: 3.0,
                    ),
                  ),
                ),
                Spacer(),
                if (_controller.resolutionPreset != ResolutionPreset.max)
                  _captureControlRowWidget()
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_controller != null) {
        _onNewCameraSelected(_controller.description);
      }
    }
  }

  Widget _cameraPreviewWidget() {
    if (_controller == null || !_controller.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: CameraPreview(_controller),
          ),
          if (_controller.resolutionPreset == ResolutionPreset.max)
            _captureControlRowWidget(),
          if (_controller != null &&
              _controller.value.isInitialized &&
              _controller.value.isRecordingVideo)
            Positioned(
              right: _orientation == DeviceOrientation.portraitUp ? 10 : 0,
              top: _orientation == DeviceOrientation.portraitUp ? 10 : 20,
              child: _rotatedWidgetBuilder(Text(
                _timerString,
                style: TextStyle(color: Colors.red),
              )),
            ),
        ],
      );
    }
  }

  Widget _captureControlRowWidget() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white60,
            child: _rotatedWidgetBuilder(IconButton(
              icon: _controller != null && _controller.value.isRecordingPaused
                  ? Icon(Icons.play_arrow)
                  : Icon(Icons.pause),
              color: Colors.blue,
              onPressed: _controller != null &&
                      _controller.value.isInitialized &&
                      _controller.value.isRecordingVideo
                  ? (_controller != null && _controller.value.isRecordingPaused
                      ? _resumeVideoRecording
                      : _pauseVideoRecording)
                  : null,
            )),
          ),
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white60,
            child: IconButton(
              icon: const Icon(Icons.camera),
              iconSize: 40,
              color: Colors.red,
              onPressed: _controller != null &&
                      _controller.value.isInitialized &&
                      !_controller.value.isRecordingVideo
                  ? _startVideoRecording
                  : null,
            ),
          ),
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white60,
            child: IconButton(
              icon: const Icon(Icons.stop),
              color: Colors.red,
              onPressed: _controller != null &&
                      _controller.value.isInitialized &&
                      _controller.value.isRecordingVideo
                  ? () => _stopVideoRecording().then((_) {
                        Navigator.pushReplacementNamed(
                            context, UploadScreen.route,
                            arguments: File(_videoPath));
                      })
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  void _switchCamera(CameraLensDirection currentDirection) {
    final newDirection = currentDirection == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    final newCamera =
        widget.cameras.firstWhere((cam) => cam.lensDirection == newDirection);
    this._onNewCameraSelected(newCamera);
  }

  Widget _rotatedWidgetBuilder(Widget widget) {
    double angle = 0;
    if (_orientation == DeviceOrientation.landscapeLeft)
      angle = (pi / 2);
    else if (_orientation == DeviceOrientation.landscapeRight)
      angle = -(pi / 2);
    return Transform.rotate(
      angle: angle,
      child: widget,
    );
  }

  Future<void> _changeAspectRatio() async {
    if (_controller != null) {
      await _controller.dispose();
    }
    var resolution = _controller.resolutionPreset;
    if (resolution == ResolutionPreset.low)
      resolution = ResolutionPreset.medium;
    else if (resolution == ResolutionPreset.medium)
      resolution = ResolutionPreset.max;
    else
      resolution = ResolutionPreset.low;

    _controller = CameraController(
      _controller.description,
      resolution,
      enableAudio: _controller.enableAudio,
    );

    _controller.addListener(() {
      if (mounted) setState(() {});
      if (_controller.value.hasError) {
        _showInSnackBar('Camera error ${_controller.value.errorDescription}');
      }
    });

    try {
      await _controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    } finally {}

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _onNewCameraSelected(CameraDescription camera) async {
    if (_controller != null) {
      await _controller.dispose();
    }
    _controller = CameraController(
      camera,
      _controller.resolutionPreset,
      enableAudio: _controller.enableAudio,
    );

    _controller.addListener(() {
      if (mounted) setState(() {});
      if (_controller.value.hasError) {
        _showInSnackBar('Camera error ${_controller.value.errorDescription}');
      }
    });

    try {
      await _controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    } finally {}

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _pauseVideoRecording() async {
    if (!_controller.value.isRecordingVideo) {
      return null;
    }
    _timer.cancel();

    try {
      await _controller.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    } finally {
      if (mounted) setState(() {});
    }
  }

  Future<void> _resumeVideoRecording() async {
    if (!_controller.value.isRecordingVideo) {
      return null;
    }

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _recordingTime++;
      _setTimerString();
    });

    try {
      await _controller.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    } finally {
      if (mounted) setState(() {});
    }
  }

  void _setTimerString() {
    final minutes = (_recordingTime / 60).floor();
    final seconds = _recordingTime - 60 * minutes;
    setState(() {
      _timerString =
          '${minutes < 10 ? '0' : ''}$minutes:${seconds < 10 ? '0' : ''}$seconds';
    });
  }

  void _showCameraException(CameraException e) {
    widget.logError(e.code, e.description);
    _showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  void _showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<String> _startVideoRecording() async {
    if (!_controller.value.isInitialized) {
      _showInSnackBar('Error: no camera available.');
      return null;
    }

    _recordingTime = 0;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _recordingTime++;
      _setTimerString();
    });

    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/salto/videos';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${_timestamp()}.mp4';

    if (_controller.value.isRecordingVideo) {
      return null;
    }

    try {
      this._videoPath = filePath;
      await _controller.startVideoRecording(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    if (mounted) setState(() {});
    return filePath;
  }

  Future<void> _stopVideoRecording() async {
    if (!_controller.value.isRecordingVideo) {
      return null;
    }
    _timer.cancel();
    try {
      await _controller.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  String _timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
}
