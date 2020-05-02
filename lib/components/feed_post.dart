import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salto/components/add_comment.dart';
import 'package:salto/components/circle_avatar_button.dart';
import 'package:salto/components/dark_dialog.dart';
import 'package:salto/components/file_video_player.dart';
import 'package:salto/components/timestamp.dart';
import 'package:salto/models/comment.dart';
import 'package:salto/models/content-item.dart';
import 'package:salto/models/http_exception.dart';
import 'package:salto/models/user.dart';
import 'package:salto/providers/comments.dart';
import 'package:salto/providers/content-items.dart';
import 'package:salto/providers/users.dart';
import 'package:salto/screens/comments_screen.dart';
import 'package:salto/screens/profile_screen.dart';

import 'comment_widget.dart';
import 'confirm_dialog.dart';

class FeedPost extends StatefulWidget {
  ContentItem post;

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
  String _updatingTitle;
  String _updatingDescription;
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  static const List<String> menuEntries = <String>[
    'Edit',
    'Delete',
  ];

  @override
  void dispose() {
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _updatingTitle = widget.post.title;
    _updatingDescription = widget.post.description;
    _signedInUser = Provider.of<Users>(context, listen: false).signedInUser;
    _postUser = Provider.of<Users>(context, listen: false).findById(widget.post.userId);
    if (_isInit) {
      _isFavorite = ContentItem.isFavorite(widget.post, _signedInUser.id);
    }
    return Center(
      child: Card(
        key: widget.key,
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
                hasLine: false,
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
        SizedBox(width: 5),
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
          _comments.length > 3
              ? InkWell(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'more',
                        style: TextStyle(color: Theme.of(context).accentColor),
                      ),
                    ],
                  ),
                  onTap: () => Navigator.of(context)
                      .pushNamed(CommentsScreen.route, arguments: {
                    'postId': widget.post.id,
                    'postUser': _postUser,
                    'signedInUser': _signedInUser,
                  }),
                )
              : SizedBox(),
        ],
      ),
    );
  }

  Widget _headerRowBuilder() {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(
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
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Spacer(),
          _postUser.id == _signedInUser.id
              ? PopupMenuButton(
                  onSelected: _choiceAction,
                  itemBuilder: (BuildContext ctx) {
                    return menuEntries
                        .map((entry) => PopupMenuItem<String>(
                            value: entry, child: Text(entry)))
                        .toList();
                  },
                )
              : SizedBox(height: 0),
        ],
      ),
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

  void _choiceAction(String choice) {
    if (choice == 'Delete') {
      _deletePostDialog();
    } else if (choice == 'Edit') {
      _editFormDialog();
    }
  }

  void _deletePostDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ConfirmDialog(
            callback: () async {
              await Provider.of<ContentItems>(context)
                  .deleteContent(widget.post.id);
              Navigator.pop(context);
            },
            statement: 'Remove this post?',
          );
        });
  }

  void _editFormDialog() {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          final content = Form(
            key: _form,
            child: Container(
              height: 180,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    autofocus: true,
                    initialValue: widget.post.title,
                    decoration: InputDecoration(labelText: 'Title'),
                    textInputAction: TextInputAction.next,
                    focusNode: _titleFocusNode,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(ctx).requestFocus(_descriptionFocusNode),
                    onSaved: (value) => _updatingTitle = value,
                  ),
                  TextFormField(
                    initialValue: widget.post.description,
                    decoration: InputDecoration(labelText: 'Description'),
                    textInputAction: TextInputAction.done,
                    focusNode: _descriptionFocusNode,
                    onFieldSubmitted: (_) => _saveForm(),
                    onSaved: (value) => _updatingDescription = value,
                  ),
                  Spacer(),
                  Row(
                    children: <Widget>[
                      FlatButton(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Spacer(),
                      FlatButton(
                        child: Text('Update'),
                        onPressed: _saveForm,
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
          return DarkDialog(
            content: content,
            statement: 'Update post',
            brightMode: true,
          );
        });
  }

  void _saveForm() async {
    try {
      Navigator.of(context).pop();
      _form.currentState.save();
      if (_updatingTitle != widget.post.title) {
        setState(() {
          widget.post = ContentItem(
            id: widget.post.id,
            title: _updatingTitle,
            userId: widget.post.userId,
            likes: widget.post.likes,
            mediaUrl: widget.post.mediaUrl,
            timestamp: widget.post.timestamp,
            description: widget.post.description,
          );
        });
        await Provider.of<ContentItems>(context, listen: false)
            .updatePost('title', _updatingTitle, widget.post.id);
      }
      if (_updatingDescription != widget.post.description) {
        setState(() {
          widget.post = ContentItem(
            id: widget.post.id,
            title: widget.post.title,
            userId: widget.post.userId,
            likes: widget.post.likes,
            mediaUrl: widget.post.mediaUrl,
            timestamp: widget.post.timestamp,
            description: _updatingDescription,
          );
        });
        await Provider.of<ContentItems>(context, listen: false)
            .updatePost('description', _updatingDescription, widget.post.id);
      }
    } on HttpException catch (_) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to update post.')));
    }
  }

  Future<void> _toggleFavorite() async {
    await Provider.of<ContentItems>(context)
        .toggleFavorites(widget.post, this._signedInUser.id);
    setState(() {
      this._isFavorite = !this._isFavorite;
    });
  }
}
