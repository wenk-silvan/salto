import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salto/components/circle_avatar_button.dart';
import 'package:salto/components/file_video_player.dart';
import 'package:salto/components/timestamp.dart';
import 'package:salto/models/content-item.dart';
import 'package:salto/models/user.dart';
import 'package:salto/providers/content-items.dart';
import 'package:salto/providers/users.dart';
import 'package:salto/screens/post_screen.dart';

class FeedPost extends StatefulWidget {
  final ContentItem post;

  FeedPost(this.post);

  @override
  _FeedPostState createState() => _FeedPostState();
}

class _FeedPostState extends State<FeedPost> {
  bool _isInit = true;
  bool _isFavorite;
  User _signedInUser;

  Future<void> _toggleFavorite() async {
    await Provider.of<ContentItems>(context)
        .toggleFavorites(widget.post, this._signedInUser.id);
    setState(() {
      this._isFavorite = !this._isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    this._signedInUser = Provider.of<Users>(context).signedInUser;
    final user = Provider.of<Users>(context).findById(widget.post.userId);
    if (this._isInit) {
      this._isFavorite =
          ContentItem.isFavorite(widget.post, this._signedInUser.id);
    }
    return Center(
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, PostScreen.route, arguments: {
          'contentItemId': widget.post.id,
        }),
        //child: Image.network(widget.post.mediaUrl, fit: BoxFit.cover),
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatarButton(user, Colors.white),
                  Text(
                    "@${user.userName}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                  width: double.infinity,
                  child: widget.post.mediaUrl.isNotEmpty
                      ? FileVideoPlayer(true, File(''), widget.post.mediaUrl)
                      : Text("")),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    IconButton(
                      iconSize: 30,
                      color: Colors.red,
                      icon: Icon(this._isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border),
                      onPressed: () => this._toggleFavorite(),
                    ),
                    IconButton(
                      iconSize: 30,
                      icon: Icon(Icons.comment),
                      onPressed: () => Navigator.pushNamed(
                          context, PostScreen.route,
                          arguments: {
                            'contentItemId': widget.post.id,
                          }),
                    ),
                    Spacer(),
                    Timestamp(widget.post.timestamp),
                  ],
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.only(top: 0, bottom: 8.0, left: 8.0, right: 8.0),
                child: Text(
                  widget.post.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.only(top: 0, bottom: 8.0, left: 8.0, right: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(widget.post.description),
                  ],
                ),
              ),
            ],
          ), //
        ),
      ),
    );
  }
}
