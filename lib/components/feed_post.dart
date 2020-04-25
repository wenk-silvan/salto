import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salto/components/add_comment.dart';
import 'package:salto/components/circle_avatar_button.dart';
import 'package:salto/components/file_video_player.dart';
import 'package:salto/components/timestamp.dart';
import 'package:salto/models/comment.dart';
import 'package:salto/models/content-item.dart';
import 'package:salto/models/user.dart';
import 'package:salto/providers/comments.dart';
import 'package:salto/providers/content-items.dart';
import 'package:salto/providers/users.dart';
import 'package:salto/screens/comment_screen.dart';
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
  User _postUser;

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
    this._postUser = Provider.of<Users>(context).findById(widget.post.userId);
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
              _headerRowBuilder(),
              _videoPlayerBuilder(),
              _actionRowBuilder(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  widget.post.title,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(widget.post.description),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AddComment(postId: widget.post.id, userId: _postUser.id),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionRowBuilder() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        IconButton(
          iconSize: 30,
          color: Colors.red,
          icon: Icon(this._isFavorite ? Icons.favorite : Icons.favorite_border),
          onPressed: () => this._toggleFavorite(),
        ),
        IconButton(
          iconSize: 30,
          icon: Icon(Icons.comment),
          onPressed: () =>
              Navigator.pushNamed(context, CommentScreen.route, arguments: {
            'postId': widget.post.id,
            'user': this._postUser,
          }),
        ),
        Spacer(),
        Timestamp(widget.post.timestamp),
      ],
    );
  }

  Widget _headerRowBuilder() {
    return Row(
      children: <Widget>[
        CircleAvatarButton(_postUser, Colors.white),
        Text(
          "@${_postUser.userName}",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _videoPlayerBuilder() {
    return Container(
      width: double.infinity,
      child: widget.post.mediaUrl.isNotEmpty
          ? FileVideoPlayer(true, File(''), widget.post.mediaUrl)
          : Text(""),
    );
  }
}
