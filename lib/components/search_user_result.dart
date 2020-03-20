import 'package:flutter/material.dart';
import 'package:salto/components/circle_avatar_button.dart';
import 'package:salto/models/user.dart';
import 'package:salto/screens/profile_screen.dart';

class SearchUserResult extends StatelessWidget {
  User user;

  SearchUserResult(this.user);

  _navigateToProfile(BuildContext ctx) {
    Navigator.pushNamed(ctx, ProfileScreen.route, arguments: {
      'userId': this.user.id,
      'currentUserId': this.user.id, //TODO: Use ID of signed in User.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => this._navigateToProfile(context),
        child: Row(
          children: <Widget>[
            CircleAvatarButton(this.user),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '${this.user.firstName} ${this.user.lastName}',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '@${this.user.userName}',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
