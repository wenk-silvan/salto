import 'package:flutter/material.dart';
import 'package:salto/components/feed_post.dart';
import 'package:provider/provider.dart';
import 'package:salto/models/user.dart';
import 'package:salto/providers/content-items.dart';

class FeedScreen extends StatefulWidget {
  final bool isFavorites;
  final User currentUser;

  FeedScreen({@required this.isFavorites, this.currentUser});

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  /*@override
  void initState() {
    Future.delayed(Duration.zero).then((_) =>
      Provider.of<ContentItems>(context).getContent());
    super.initState();
  }*/

  @override
  Widget build(BuildContext context) {
    /*final contentData = Provider.of<ContentItems>(context);
    List<ContentItem> content = widget.isFavorites
        ? contentData.getContentOfUsers(widget.currentUser.follows)
        : contentData.items;*/

    return RefreshIndicator(
      onRefresh: () {
        //TODO: Fetch content
        return null;
      },
      child: FutureBuilder(
        future: Provider.of<ContentItems>(context, listen: false)
            .getContent(widget.currentUser),
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (dataSnapshot.error != null) {
              // ...
              // Do error handling stuff
              return Center(
                child: Text('An error occurred!'),
              );
            } else {
              return widget.isFavorites
                  ? Consumer<ContentItems>(
                      builder: (ctx, orderData, child) => ListView.builder(
                        itemBuilder: (_, i) => FeedPost(orderData.favItems[i]),
                        itemCount: orderData.favItems.length,
                      ),
                    )
                  : Consumer<ContentItems>(
                      builder: (ctx, orderData, child) => ListView.builder(
                        itemBuilder: (_, i) => FeedPost(orderData.items[i]),
                        itemCount: orderData.items.length,
                      ),
                    );
            }
          }
        },
      ),
    );
  }
}
