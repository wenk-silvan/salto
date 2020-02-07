import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:salto/dummy_data.dart';
import 'package:salto/screens/settings_screen.dart';
import 'package:salto/screens/profile_screen.dart';
import 'package:salto/screens/upload_screen.dart';

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget{

  BaseAppBar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("Salto"),
      actions: <Widget>[
        IconButton(
          icon : Icon(Icons.search),
          onPressed: () {
            // TODO: open search screen
          },
        ),
        IconButton(
            icon : Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UploadScreen())
              );
            }
        ),
        IconButton(
          icon : Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen())
            );
          }
        ),
        GestureDetector(
          child: new Padding(
            padding: const EdgeInsets.only(right: 10.0),
              child: CircleAvatar(
                  child: ClipOval(
                    child: Image.network(getDummyUsers()[0].avatarUrl),
                  )
              )
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen())
            );
          }
        )

      ],
    );

  }
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}