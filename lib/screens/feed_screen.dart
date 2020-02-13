import 'package:flutter/material.dart';
import 'package:salto/components/feed_post.dart';
import 'package:provider/provider.dart';
import 'package:salto/models/user.dart';
import 'package:salto/providers/content-items.dart';
import 'package:salto/providers/users.dart';
import '../models/content-item.dart';

class FeedScreen extends StatefulWidget {
  final bool isFavorites;
  final User currentUser;

  FeedScreen({@required this.isFavorites, this.currentUser});

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    final contentData = Provider.of<ContentItems>(context);
    List<ContentItem> content = widget.isFavorites
        ? contentData.getContentOfUsers(widget.currentUser.follows)
        : contentData.items;

    return RefreshIndicator(
      onRefresh: () {
        //TODO: Fetch content
        return null;
      },
      child: ListView.builder(
        itemBuilder: (_, i) => FeedPost(content[i]),
        itemCount: content.length,
      ),
    );
  }
}
