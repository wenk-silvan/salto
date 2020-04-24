import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:salto/screens/camera_screen.dart';
import 'package:salto/screens/upload_screen.dart';

class AddPostDialog extends StatelessWidget {
  void _chooseVideoAndNavigate(BuildContext ctx) async {
    final File file = await FilePicker.getFile(type: FileType.video);
    print('Picked file from path: ${file.path}');
    Navigator.of(ctx).pushReplacementNamed(UploadScreen.route, arguments: file);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add new post'),
      content: Text('How would you like to upload a video?'),
      actions: <Widget>[
        FlatButton(
          child: Text('Take Video'),
          onPressed: () => Navigator.of(context).pushReplacementNamed(CameraScreen.route),
        ),
        FlatButton(
          child: Text('From Gallery'),
          onPressed: () => this._chooseVideoAndNavigate(context),
        ),
      ],
    );
  }
}
