import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:salto/components/circle_avatar_button.dart';
import 'package:salto/screens/search_screen.dart';
import 'package:salto/screens/settings_screen.dart';
import 'package:salto/screens/upload_screen.dart';

import '../models/user.dart';

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
  final User user;

  BaseAppBar(this.user, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                            // TODO: open camera
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pushNamed(
                                  UploadScreen.route,
                                  arguments: this.user.id);
                            }),
                        FlatButton(
                            child: Text('From Gallery'),
                            //TODO: select video from galley
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pushNamed(
                                  UploadScreen.route,
                                  arguments: this.user.id);
                            }),
                      ],
                    );
                  });
            }),
        IconButton(
            icon: Icon(Icons.settings),
            onPressed: () =>
                Navigator.of(context).pushNamed(SettingsScreen.route)),
        CircleAvatarButton(this.user),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
