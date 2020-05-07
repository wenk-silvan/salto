import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:salto/components/circle_avatar_button.dart';
import 'package:salto/components/feed.dart';
import 'package:salto/components/feed_post.dart';
import 'package:provider/provider.dart';
import 'package:salto/models/content-item.dart';
import 'package:salto/models/user.dart';
import 'package:salto/providers/auth.dart';
import 'package:salto/providers/content-items.dart';
import 'package:salto/providers/users.dart';
import 'package:salto/screens/splash_screen.dart';

class FeedScreen extends StatelessWidget {
  static const route = '/feed';

  List<ContentItem> posts;
  Feed feed;

  @override
  Widget build(BuildContext context) {
    if (!Provider.of<Auth>(context).isAuth) {
      Navigator.of(context).pop();
      return SplashScreen();
    }
    var args = ModalRoute.of(context).settings.arguments as dynamic;
    final User user = args['user'];
    final int startIndex = args['startIndex'] == null ? 0 : args['startIndex'];

    this.posts =
        Provider.of<ContentItems>(context).getContentByUserId(user.id);
    this.feed = Feed(this.posts, startIndex);
    return Scaffold(
      appBar: AppBar(
        title: Text('Posts of @' + user.userName),
        actions: <Widget>[
          CircleAvatarButton(user, Theme.of(context).primaryColor, true)
        ],
      ),
      body: this.feed,
    );
  }
}

