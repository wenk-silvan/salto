import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:salto/components/dark_dialog.dart';
import 'package:salto/screens/camera_screen.dart';
import 'package:salto/screens/upload_screen.dart';

class AddPostDialog extends StatelessWidget {
  final String statement;

  AddPostDialog({this.statement});

  void _chooseVideoAndNavigate(BuildContext ctx) async {
    final File file = await FilePicker.getFile(type: FileType.video);
    print('Picked file from path: ${file.path}');
    Navigator.of(ctx).pushReplacementNamed(UploadScreen.route, arguments: file);
  }

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        FlatButton(
          child: Text('Take Video', style: TextStyle(color: Colors.white)),
          onPressed: () =>
              Navigator.of(context).pushReplacementNamed(CameraScreen.route),
        ),
        FlatButton(
          child: Text('From Gallery', style: TextStyle(color: Colors.white)),
          onPressed: () => this._chooseVideoAndNavigate(context),
        ),
      ],
    );
    return DarkDialog(
      content: content,
      statement: 'Select your video.',
      brightMode: false,
    );
  }
}
