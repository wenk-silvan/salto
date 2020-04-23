import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:salto/components/feed_post.dart';
import 'package:provider/provider.dart';
import 'package:salto/models/user.dart';
import 'package:salto/providers/content-items.dart';
import 'package:salto/providers/users.dart';

class FeedScreen extends StatelessWidget {
  final bool isFavorites;

  FeedScreen({@required this.isFavorites});

  Future<void> _initialize(BuildContext ctx, User signedInUser) async {
    await Provider.of<ContentItems>(ctx, listen: false)
        .getContent(signedInUser);
  }

  @override
  Widget build(BuildContext context) {
    var signedInUser = Provider.of<Users>(context).signedInUser;
    return FutureBuilder(
      future: _initialize(context, signedInUser),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          if (snapshot.hasError) {
            print(snapshot.error);
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
