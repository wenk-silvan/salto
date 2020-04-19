import 'dart:io';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salto/components/circle_avatar_button.dart';
import 'package:salto/providers/users.dart';
import 'package:salto/screens/camera_screen.dart';
import 'package:salto/screens/search_screen.dart';
import 'package:salto/screens/settings_screen.dart';
import 'package:salto/screens/upload_screen.dart';

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
  void _chooseVideoAndNavigate(BuildContext ctx) async {
    final File file = await FilePicker.getFile(type: FileType.video);
    print('Picked file from path: ${file.path}');
    Navigator.of(ctx).pushNamed(UploadScreen.route, arguments: file);
  }

  @override
  Widget build(BuildContext context) {
    var signedInUser = Provider.of<Users>(context).signedInUser;
    return AppBar(
      title: Text('Salto'),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            Navigator.of(context).pushNamed(SearchScreen.route);
          },
        ),
        IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext ctx) {
                    return AlertDialog(
                      title: Text('Add new post'),
                      content: Text('How would you like to upload a video?'),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('Take Video'),
                          onPressed: () =>
                              Navigator.of(ctx).pushNamed(CameraScreen.route),
                        ),
                        FlatButton(
                          child: Text('From Gallery'),
                          onPressed: () =>
                              this._chooseVideoAndNavigate(context),
                        ),
                      ],
                    );
                  });
            }),
        IconButton(
            icon: Icon(Icons.settings),
            onPressed: () =>
                Navigator.of(context).pushNamed(SettingsScreen.route)),
        CircleAvatarButton(signedInUser, Theme.of(context).primaryColor),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
