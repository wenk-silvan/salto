import 'package:flutter/material.dart';
import 'package:salto/components/feed_post.dart';
import 'package:provider/provider.dart';
import 'package:salto/models/user.dart';
import 'package:salto/providers/content-items.dart';

class FeedScreen extends StatelessWidget {
  final bool isFavorites;
  final User currentUser;

  FeedScreen({@required this.isFavorites, this.currentUser});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<ContentItems>(context, listen: false)
          .getContent(this.currentUser),
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
            return this.isFavorites
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
    );
  }
}
