import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salto/components/circle_avatar_button.dart';
import 'package:salto/providers/users.dart';
import 'package:salto/screens/search_screen.dart';
import 'package:salto/screens/settings_screen.dart';
import 'package:salto/screens/upload_screen.dart';

import '../models/user.dart';

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
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
                            // TODO: open camera
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pushNamed(UploadScreen.route);
                            }),
                        FlatButton(
                            child: Text('From Gallery'),
                            //TODO: select video from galley
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pushNamed(UploadScreen.route);
                            }),
                      ],
                    );
                  });
            }),
        IconButton(
            icon: Icon(Icons.settings),
            onPressed: () =>
                Navigator.of(context).pushNamed(SettingsScreen.route)),
        CircleAvatarButton(signedInUser),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
