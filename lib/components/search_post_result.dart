import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:salto/models/content-item.dart';
import 'package:salto/providers/content-items.dart';
import 'package:salto/providers/users.dart';
import 'package:salto/screens/feed_screen.dart';

import 'circle_avatar_button.dart';

class SearchPostResult extends StatelessWidget {
  ContentItem post;

  SearchPostResult(this.post);

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<Users>(context, listen: false).findById(this.post.userId);
    var startIndex = Provider.of<ContentItems>(context, listen: false).getContentByUserId(user.id).indexOf(post);
    if (startIndex == -1) startIndex = 0;
    return Card(
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, FeedScreen.route, arguments: {
          'user': user,
          'startIndex': startIndex,
        }),
        child: Row(
          children: <Widget>[
            CircleAvatarButton(user, Colors.white),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      this.post.title,
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          '@${user.userName.length > 13 ? user.userName.substring(0, 12) + '...' : user.userName}',
                        ),
                        Spacer(),
                        Text(
                          DateFormat('dd.MM.yyyy').format(this.post.timestamp),
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        SizedBox(width: 10),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.favorite,
                              size: 20,
                              color: Colors.red,
                            ),
                            SizedBox(width: 2),
                            Text(
                              this.post.likes.length.toString(),
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
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
