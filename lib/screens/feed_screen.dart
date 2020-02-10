import 'package:flutter/material.dart';
import 'package:salto/dummy_data.dart';
import 'package:salto/components/feed_post.dart';

import '../dummy_data.dart';

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    return ListView(
        children: <Widget>[
          FeedPost(DUMMY_CONTENT[0]),
          FeedPost(DUMMY_CONTENT[0]),
          FeedPost(DUMMY_CONTENT[0]),
        ],
    );
  }
}
