import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salto/components/circle_avatar_button.dart';
import 'package:salto/models/comment.dart';
import 'package:salto/models/content-item.dart';
import 'package:salto/models/user.dart';
import 'package:salto/providers/content-items.dart';
import 'package:salto/providers/users.dart';
import 'package:salto/screens/profile_screen.dart';
import 'package:salto/components/comment_widget.dart';

class FeedPost extends StatefulWidget {
  final ContentItem post;

  FeedPost(this.post);

  @override
  _FeedPostState createState() => _FeedPostState();
}

class _FeedPostState extends State<FeedPost> {
  bool _isFavorite;
  User _signedInUser;

  Future<void> _toggleFavorite() async {
    if (!this._isFavorite) {
      await Provider.of<ContentItems>(context, listen: false)
          .addToFavorites(widget.post, this._signedInUser.id);
    } else {
      await Provider.of<ContentItems>(context, listen: false)
          .removeFromFavorites(widget.post, this._signedInUser.id);
    }
  }

  void _setIsFavorite() {
    setState(() {
      this._isFavorite = widget.post.likes.any((l) => l == this._signedInUser.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    this._signedInUser = Provider.of<Users>(context).signedInUser;
    this._setIsFavorite();
    final user = Provider.of<Users>(context).findById(widget.post.userId);
    return Center(
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                //Avatar
                CircleAvatarButton(user),
                Text(
                  widget.post.title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              child: Image.network(widget.post.mediaUrl, fit: BoxFit.cover),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: Icon(
                        this._isFavorite ? Icons.favorite : Icons.favorite_border),
                    onPressed: () {
                      this._toggleFavorite().then((_) {
                        this._setIsFavorite();
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.comment),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.only(right: 8.0, left: 8.0, bottom: 6.0),
              child: Text(widget.post.description),
            ),
            Padding(
              padding: EdgeInsets.only(right: 8.0, left: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.post.comments
                    .map((Comment c) => CommentWidget(c))
                    .toList(),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text('10-02-2020',
                      style: TextStyle(color: Colors.grey, fontSize: 12))
                ], // TODO: calculate & print timestamp
              ),
            ),
          ],
        ), //
      ),
    );
  }
}
