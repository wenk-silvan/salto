import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salto/components/circle_avatar_button.dart';
import 'package:salto/components/comment_widget.dart';
import 'package:salto/components/confirm_dialog.dart';
import 'package:salto/components/file_video_player.dart';
import 'package:salto/components/timestamp.dart';
import 'package:salto/models/comment.dart';
import 'package:salto/models/content-item.dart';
import 'package:salto/models/http_exception.dart';
import 'package:salto/models/user.dart';
import 'package:salto/providers/comments.dart';
import 'package:salto/providers/content-items.dart';
import 'package:salto/providers/users.dart';
import 'package:salto/screens/feed_screen.dart';

class PostScreen extends StatefulWidget {
  static const route = '/player';
  final storageUrl = "salto-7fab8.appspot.com";
  final FirebaseStorage storage;

  PostScreen({Key key, this.storage}) : super(key: key);

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  bool _isInit = true;
  final TextEditingController _input = new TextEditingController();
  User _signedInUser;
  User _user;
  ContentItem _cachedPost;
  ContentItem _post;
  bool _isFavorite;
  List<Comment> _comments;

  void _confirmDeletePost() {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          // return object of type Dialog
          return ConfirmDialog(
            header: 'Removal of Post',
            statement: 'Are you sure to delete the post?',
            callback: () async {
              await Provider.of<ContentItems>(ctx, listen: false).deleteContent(_post.id);
              _removeVideo(ctx);
              Navigator.pushReplacementNamed(context, '/');
            },
          );
        });
  }

  void _initialize() {
    final args = ModalRoute.of(context).settings.arguments as dynamic;
    final postId = args['contentItemId'];
    this._post = Provider.of<ContentItems>(context, listen: false)
        .getContentById(postId);
    this._user =
        Provider.of<Users>(context, listen: false).findById(this._post.userId);
    this._signedInUser =
        Provider.of<Users>(context, listen: false).signedInUser;
    if (this._cachedPost != null && this._cachedPost.id != this._post.id) {
      this._isInit = true;
    }
    if (this._isInit) {
      this._isFavorite =
          ContentItem.isFavorite(this._post, this._signedInUser.id);
      this._cachedPost = this._post;
    }
  }

  void _removeVideo(BuildContext ctx) async {
    await widget.storage.ref().child('videos').child('${_post.id}.mp4').delete();
  }

  void _submitComment() async {
    if (this._input.text.isEmpty) return;
    try {
      this._isInit = true;
      await Provider.of<Comments>(context).addComment(
          Comment(
            userId: this._signedInUser.id,
            timestamp: DateTime.now(),
            text: this._input.text,
            id: '',
          ),
          this._post.id);
    } on HttpException catch (error) {
      HttpException.showErrorDialog(error.toString(), context);
    }
  }

  Future<void> _toggleFavorite() async {
    await Provider.of<ContentItems>(context)
        .toggleFavorites(this._post, this._signedInUser.id);
    setState(() {
      this._isFavorite = !this._isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    this._initialize();
    return Scaffold(
      appBar: AppBar(
        title: Text(this._post.title),
        actions: <Widget>[
          CircleAvatarButton(_user, Theme.of(context).primaryColor, true),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FileVideoPlayer(true, File(''), this._post.mediaUrl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  iconSize: 30,
                  color: Colors.red,
                  icon: Icon(this._isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border),
                  onPressed: () => this._toggleFavorite(),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Timestamp(this._post.timestamp),
                ),
                if (_user.id == _signedInUser.id)
                  IconButton(
                    iconSize: 30,
                    color: Colors.red,
                    icon: Icon(Icons.delete),
                    onPressed: this._confirmDeletePost,
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: Text(this._post.description,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Card(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FutureBuilder(
                        future: this._isInit
                            ? Provider.of<Comments>(context, listen: false)
                                .getComments(this._post.id)
                            : null,
                        builder: (ctx, authResultSnapshot) {
                          this._isInit = false;
                          if (authResultSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else {
                            this._comments =
                                Provider.of<Comments>(context, listen: false)
                                    .items;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                this._comments.length > 0
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: this
                                            ._comments
                                            .map(
                                                (Comment c) => CommentWidget(c))
                                            .toList())
                                    : Text('No comments available.'),
                                TextField(
                                  controller: _input,
                                  onSubmitted: (_) => this._submitComment,
                                  decoration: new InputDecoration(
                                      hintText: 'Add comment...',
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.all(2),
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          child: ClipOval(
                                            child: Image.network(
                                              this._signedInUser != null
                                                  ? this._signedInUser.avatarUrl
                                                  : '',
                                              fit: BoxFit.cover,
                                              width: 35.0,
                                              height: 35.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(Icons.keyboard_arrow_right),
                                        onPressed: () {
                                          this._submitComment();
                                          this._input.clear();
                                        },
                                      )),
                                )
                              ],
                            );
                          }
                        })),
              ),
            ),
          ],
        ),
      ), //
    );
  }
}
