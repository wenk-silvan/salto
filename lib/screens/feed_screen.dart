import 'package:flutter/material.dart';
import 'package:salto/components/feed_post.dart';
import 'package:provider/provider.dart';
import 'package:salto/providers/content-items.dart';
import '../models/content-item.dart';
import '../models/content-item.dart';

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    List<ContentItem> content = Provider.of<ContentItems>(context).items;

    return RefreshIndicator(
      onRefresh: () {
        //TODO: Fetch content.
      },
      child: ListView(
        children: <Widget>[
          FeedPost(content[0]),
          FeedPost(content[0]),
          FeedPost(content[0]),
        ],
      ),
    );
  }
}
