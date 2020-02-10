import 'package:flutter/material.dart';
import 'package:salto/components/base_app_bar.dart';
import 'package:salto/dummy_data.dart';
import 'package:salto/components/feed_post.dart';

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    var dummyPosts = getDummyPosts();
    return Scaffold(
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
