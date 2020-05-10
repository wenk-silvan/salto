import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salto/components/add_comment.dart';
import 'package:salto/components/circle_avatar_button.dart';
import 'package:salto/components/dark_dialog.dart';
import 'package:salto/components/edit_post.dart';
import 'package:salto/components/file_video_player.dart';
import 'package:salto/components/post_comments.dart';
import 'package:salto/components/timestamp.dart';
import 'package:salto/models/content-item.dart';
import 'package:salto/models/user.dart';
import 'package:salto/providers/comments.dart';
import 'package:salto/providers/content-items.dart';
import 'package:salto/providers/storage.dart';
import 'package:salto/providers/users.dart';
import 'package:salto/screens/profile_screen.dart';
import 'confirm_dialog.dart';
import 'package:salto/models/http_exception.dart';

class FeedPost extends StatelessWidget {
  final ContentItem post;
  static const List<String> menuEntries = <String>[
    'Edit',
    'Delete',
  ];

  FeedPost(this.post);

  bool _showComments = false;
  User _postUser;
  User _signedInUser;

  @override
  Widget build(BuildContext context) {
    _signedInUser = Provider.of<Users>(context, listen: false).signedInUser;
    _postUser =
        Provider.of<Users>(context, listen: false).findById(this.post.userId);
    return Center(
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _headerRowBuilder(context),
            _videoPlayerBuilder(),
            _actionRowBuilder(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                this.post.title,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(this.post.description),
            ),
            SizedBox(height: _showComments ? 15 : 0),
            _showComments
                ? PostComments(this.post, {
                    'postId': this.post.id,
                    'postUser': _postUser,
                    'signedInUser': _signedInUser,
                  })
                : const SizedBox(height: 0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: AddComment(
                postId: this.post.id,
                userId: _signedInUser.id,
                hasLine: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionRowBuilder(BuildContext ctx) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        IconButton(
          iconSize: 30,
          color: Colors.red,
          icon: Icon(ContentItem.isFavorite(this.post, _signedInUser.id)
              ? Icons.favorite
              : Icons.favorite_border),
          onPressed: () => _toggleFavoritesFuture(ctx),
        ),
        IconButton(
          iconSize: 30,
          icon: const Icon(Icons.comment),
          onPressed: () {
            _showComments = !_showComments;
            Provider.of<Comments>(ctx).trigger();
          },
        ),
        Spacer(),
        Timestamp(this.post.timestamp),
        const SizedBox(width: 5),
      ],
    );
  }

  Widget _headerRowBuilder(BuildContext ctx) {
    return InkWell(
      onTap: () => Navigator.of(ctx).pushNamed(
        ProfileScreen.route,
        arguments: {
          'userId': _postUser.id,
        },
      ),
      child: Row(
        children: <Widget>[
          CircleAvatarButton(_postUser, Colors.white),
          Text(
            "@${_postUser.userName}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Spacer(),
          _postUser.id == _signedInUser.id
              ? PopupMenuButton(
                  onSelected: (str) => _choiceAction(ctx, str),
                  itemBuilder: (BuildContext ctx) {
                    return FeedPost.menuEntries
                        .map((entry) => PopupMenuItem<String>(
                            value: entry, child: Text(entry)))
                        .toList();
                  },
                )
              : const SizedBox(height: 0),
        ],
      ),
    );
  }

  Widget _videoPlayerBuilder() {
    return Container(
      width: double.infinity,
      child: this.post.mediaUrl.isNotEmpty
          ? FileVideoPlayer(
              key: ObjectKey(this.post),
              loop: true,
              file: File(''),
              networkUri: this.post.mediaUrl)
          : const Text(""),
    );
  }

  void _choiceAction(BuildContext ctx, String choice) {
    if (choice == 'Delete') {
      _deletePostDialog(ctx);
    } else if (choice == 'Edit') {
      _editFormDialog(ctx);
    }
  }

  void _deletePostDialog(BuildContext ctx) {
    showDialog(
        context: ctx,
        builder: (BuildContext context) {
          return ConfirmDialog(
            callback: () async {
              try {
                await Provider.of<ContentItems>(ctx, listen: false)
                    .deleteContent(
                        Provider.of<Storage>(ctx, listen: false), this.post.id);
              } on HttpException catch (error) {
                HttpException.showErrorDialog(error.message, context);
              }
              Navigator.pop(context);
            },
            statement: 'Remove this post?',
          );
        });
  }

  void _editFormDialog(BuildContext ctx) {
    showDialog(
        context: ctx,
        builder: (BuildContext ctx) {
          final content = EditPost(this.post);
          return DarkDialog(
            content: content,
            statement: 'Update post',
            brightMode: true,
          );
        });
  }

  Future<void> _toggleFavoritesFuture(BuildContext ctx) async {
    try {
      return await Provider.of<ContentItems>(ctx)
          .toggleFavorites(this.post, this._signedInUser.id);
    } on HttpException catch (error) {
      HttpException.showErrorDialog(error.message, ctx);
      return null;
    }
  }
}
