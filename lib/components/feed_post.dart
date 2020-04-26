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

import 'comment_widget.dart';

class FeedPost extends StatefulWidget {
  final ContentItem post;

  FeedPost(this.post);

  @override
  _FeedPostState createState() => _FeedPostState();
}

class _FeedPostState extends State<FeedPost> {
  List<Comment> _comments = [];
  bool _isInit = true;
  bool _isFavorite;
  bool _showComments = false;
  User _postUser;
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
    this._postUser = Provider.of<Users>(context).findById(widget.post.userId);
    if (this._isInit) {
      this._isFavorite =
          ContentItem.isFavorite(widget.post, this._signedInUser.id);
    }
    return Center(
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
            SizedBox(height: _showComments ? 15 : 0),
            _showComments ? _commentsBuilder() : SizedBox(height: 0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: AddComment(
                postId: widget.post.id,
                userId: _signedInUser.id,
              ),
            ),
          ],
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
          onPressed: () => setState(() => _showComments = !_showComments),
        ),
        Spacer(),
        Timestamp(widget.post.timestamp),
      ],
    );
  }

  Widget _commentsBuilder() {
    return _comments.length < 1
        ? FutureBuilder(
            future: Provider.of<Comments>(context, listen: false)
                .getComments(widget.post.id),
            builder: (ctx, authResultSnapshot) {
              if (authResultSnapshot.connectionState == ConnectionState.done) {
                _comments = Provider.of<Comments>(context, listen: true).items;
                return _commentsListBuilder();
              } else {
                return Center(child: CircularProgressIndicator());
              }
            })
        : _commentsListBuilder();
  }

  Widget _commentsListBuilder() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _comments.length < 1
              ? Text('No comments available.')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _comments.length < 4
                      ? _comments.map((Comment c) => CommentWidget(c)).toList()
                      : _comments
                          .getRange(_comments.length - 3, _comments.length)
                          .map((Comment c) => CommentWidget(c))
                          .toList()),
          if (_comments.length > 3)
            GestureDetector(
              child: Row(
                children: <Widget>[
                  Text(
                    'more',
                    style: TextStyle(color: Theme.of(context).accentColor),
                  ),
                ],
              ),
              onTap: () => Navigator.of(context)
                  .pushNamed(CommentScreen.route, arguments: {
                'postId': widget.post.id,
                'postUser': _postUser,
                'signedInUser': _signedInUser,
                'comments': _comments,
              }),
            ),
        ],
      ),
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
