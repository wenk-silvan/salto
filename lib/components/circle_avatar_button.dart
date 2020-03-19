import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:salto/models/user.dart';
import 'package:salto/screens/profile_screen.dart';

class CircleAvatarButton extends StatelessWidget {
  User user;

  CircleAvatarButton(this.user);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: new Padding(
        padding: const EdgeInsets.only(
            left: 5.0, right: 10.0, top: 5.0, bottom: 10.0),
        child: CircleAvatar(
          child: ClipOval(
            child: Image.network(user.avatarUrl),
          ),
        ),
      ),
      onTap: () {
        Navigator.of(context).pushNamed(
          ProfileScreen.route,
          arguments: {
            'userId': this.user.id,
            'currentUserId': this.user.id,  //TODO: Use ID of signed in User.
          },
        );
      },
    );
  }
}
