import 'package:flutter/material.dart';
import 'package:salto/models/content-item.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'feed_post.dart';

class Feed extends StatelessWidget {
  final List<ContentItem> content;
  final _scrollController = ItemScrollController();
  final int initialIndex;

  Feed(this.content, [this.initialIndex = 0]);

  @override
  Widget build(BuildContext context) {
    if (this.content.length == 0) {
      return Center(child: Text('No content yet.'));
    }
    return ScrollablePositionedList.builder(
      initialScrollIndex: this.initialIndex,
      itemCount: this.content.length,
      itemBuilder: (BuildContext ctx, i) {
        return FeedPost(this.content[i]);
      },
    );
  }

  void jumpToIndex(int index) {
    _scrollController.scrollTo(index: index, duration: Duration(milliseconds: 500));
  }
}
