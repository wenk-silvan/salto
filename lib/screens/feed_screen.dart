import 'package:flutter/material.dart';
import 'package:salto/components/base_app_bar.dart';
import 'package:salto/dummy_data.dart';
import 'package:salto/components/feed_post.dart';

class FeedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var dummyPosts = getDummyPosts();
    return Scaffold(
      //appBar: AppBar(
      //  title: const Text('Salto dude'),
      //),
      appBar: BaseAppBar(),
      body: ListView(
        children: <Widget>[
          FeedPost(fleekBackie),
          FeedPost(dummyPosts[1]),
          FeedPost(dummyPosts[2])
        ],
      )
    );
  }
}
