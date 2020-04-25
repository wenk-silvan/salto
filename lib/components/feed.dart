import 'package:flutter/material.dart';
import 'package:salto/models/content-item.dart';

import 'feed_post.dart';

class Feed extends StatelessWidget {
  final List<ContentItem> content;

  Feed(this.content);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (_, i) => FeedPost(this.content[i]),
      itemCount: this.content.length,
    );
  }
}
