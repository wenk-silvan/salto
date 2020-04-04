import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:salto/models/user.dart';
import 'package:salto/screens/profile_screen.dart';

class CircleAvatarButton extends StatelessWidget {
  User user;
  Color backgroundColor;
  bool replacement;

  CircleAvatarButton(this.user, this.backgroundColor, [this.replacement = false]);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: new Padding(
        padding: const EdgeInsets.all(10.0),
        child: CircleAvatar(
          backgroundColor: this.backgroundColor,
          child: ClipOval(
            child: Image.network(
              user.avatarUrl,
              fit: BoxFit.cover,
              width: 90.0,
              height: 90.0,
            ),
          ),
        ),
      ),
      onTap: () {
        if(this.replacement)
          Navigator.of(context).pushReplacementNamed(
            ProfileScreen.route,
            arguments: {
              'userId': this.user.id,
            },
          );
        else
          Navigator.of(context).pushNamed(
            ProfileScreen.route,
            arguments: {
              'userId': this.user.id,
            },
          );
      },
    );
  }
}
