import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:salto/components/circle_avatar_button.dart';
import 'package:salto/components/feed.dart';
import 'package:salto/components/feed_post.dart';
import 'package:provider/provider.dart';
import 'package:salto/models/content-item.dart';
import 'package:salto/models/user.dart';
import 'package:salto/providers/content-items.dart';
import 'package:salto/providers/users.dart';

class FeedScreen extends StatelessWidget {
  static const route = '/feed';

  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context).settings.arguments as dynamic;
    final User user = args['user'];
    final posts =
        Provider.of<ContentItems>(context).getContentByUserId(user.id);
    return Scaffold(
      appBar: AppBar(
        title: Text("${user.firstName} ${user.lastName}"),
        actions: <Widget>[
          CircleAvatarButton(user, Theme.of(context).primaryColor)
        ],
      ),
      body: Feed(posts),
    );
  }
}
