import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:salto/components/circle_avatar_button.dart';
import 'package:salto/components/comment_widget.dart';
import 'package:salto/components/timestamp.dart';
import 'package:salto/models/comment.dart';
import 'package:salto/models/content-item.dart';
import 'package:salto/models/http_exception.dart';
import 'package:salto/models/user.dart';
import 'package:salto/providers/comments.dart';
import 'package:salto/providers/content-items.dart';
import 'package:salto/providers/users.dart';
import 'package:video_player/video_player.dart';

class PostScreen extends StatefulWidget {
  static const route = '/player';

  PostScreen({Key key}) : super(key: key);

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  bool _isInit = true;
  final TextEditingController _input = new TextEditingController();
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;
  User _signedInUser;
  User _user;
  ContentItem _cachedPost;
  ContentItem _post;
  bool _isFavorite;
  List<Comment> _comments;

  @override
  void initState() {
    /*_controller = VideoPlayerController.network(
      'https://www.youtube.com/embed/OyWfsDTnij8',
    );*/
    _controller = VideoPlayerController.asset(
        'assets/videos/SampleVideo_1280x720_1mb.mp4');
    _controller.setLooping(true);
    _initializeVideoPlayerFuture = _controller.initialize();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initialize() {
    final args = ModalRoute.of(context).settings.arguments as dynamic;
    this._post = Provider.of<ContentItems>(context, listen: false).getContentById(args['contentItemId']);
    this._user = Provider.of<Users>(context, listen: false).findById(this._post.userId);
    this._signedInUser = Provider.of<Users>(context, listen: false).signedInUser;
    if (this._cachedPost != null && this._cachedPost.id != this._post.id) {
      this._isInit = true;
    }
    if (this._isInit) {
      this._isFavorite = ContentItem.isFavorite(this._post, this._signedInUser.id);
      this._cachedPost = this._post;
    }
  }

  Future<void> _toggleFavorite() async {
    await Provider.of<ContentItems>(context)
        .toggleFavorites(this._post, this._signedInUser.id);
    setState(() {
      this._isFavorite = !this._isFavorite;
    });
  }

  void _toggleVideoState() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  void _submitComment() async {
    if (this._input.text.isEmpty) return;
    try {
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
            Container(
              width: double.infinity,
              child: FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: GestureDetector(
                        onTap: () => this._toggleVideoState(),
                        child: Stack(
                          children: <Widget>[
                            VideoPlayer(_controller),
                            Center(
                              child: FloatingActionButton(
                                onPressed: () => this._toggleVideoState(),
                                backgroundColor: Colors.white38,
                                child: Icon(
                                  _controller.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  iconSize: 30,
                  color: Colors.red,
                  icon: Icon(
                      this._isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border),
                  onPressed: () => this._toggleFavorite(),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Timestamp(this._post.timestamp),
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
                        future: this._isInit ? Provider.of<Comments>(context, listen: false).getComments(this._post.id) : null,
                        builder: (ctx, authResultSnapshot) {
                          this._isInit = false;
                          if (authResultSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else {
                            this._comments = Provider.of<Comments>(context, listen: false).items;
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
