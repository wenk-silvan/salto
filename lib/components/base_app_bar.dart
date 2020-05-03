import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salto/components/add_post_dialog.dart';
import 'package:salto/components/circle_avatar_button.dart';
import 'package:salto/providers/users.dart';
import 'package:salto/screens/search_screen.dart';
import 'package:salto/screens/settings_screen.dart';

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    var signedInUser = Provider.of<Users>(context).signedInUser;
    return AppBar(
      title: const Text('Salto'),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () => Navigator.of(context).pushNamed(SearchScreen.route),
        ),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () => showDialog(
              context: context,
              builder: (BuildContext ctx) => AddPostDialog(
                  statement: 'How would you like to upload a video?')),
        ),
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
