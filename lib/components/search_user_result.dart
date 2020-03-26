import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salto/components/circle_avatar_button.dart';
import 'package:salto/models/user.dart';
import 'package:salto/providers/users.dart';
import 'package:salto/screens/profile_screen.dart';

class SearchUserResult extends StatelessWidget {
  User user;

  SearchUserResult(this.user);

  _navigateToProfile(BuildContext ctx) {
    Navigator.pushNamed(ctx, ProfileScreen.route, arguments: {
      'userId': this.user.id
    });
  }

  @override
  Widget build(BuildContext context) {
    var isFollowing =
        Provider.of<Users>(context, listen: false).follows(this.user.id);
    return Card(
      child: InkWell(
        onTap: () => this._navigateToProfile(context),
        child: Row(
          children: <Widget>[
            CircleAvatarButton(user: this.user, backgroundColor: Colors.white),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${this.user.firstName} ${this.user.lastName}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '@${this.user.userName}',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    Consumer<Users>(
                      builder: (ctx, users, child) => IconButton(
                        onPressed: () => users.toggleFollowingStatus(user),
                        icon: Icon(
                            users.follows(this.user.id) ? Icons.star : Icons.star_border),
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
