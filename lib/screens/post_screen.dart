import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:salto/components/circle_avatar_button.dart';
import 'package:salto/components/comment_widget.dart';
import 'package:salto/models/comment.dart';
import 'package:salto/models/content-item.dart';
import 'package:salto/models/user.dart';
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
  final TextEditingController _input = new TextEditingController();
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;
  User _signedInUser;
  ContentItem _post;
  bool _isFavorite;

  @override
  void initState() {
    /*_controller = VideoPlayerController.network(
      'https://www.youtube.com/embed/OyWfsDTnij8',
    );*/
    _controller = VideoPlayerController.asset('assets/videos/SampleVideo_1280x720_1mb.mp4');
    _controller.setLooping(true);
    _initializeVideoPlayerFuture = _controller.initialize();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleFavorite() async {
    if (!this._isFavorite) {
      await Provider.of<ContentItems>(context, listen: false)
          .addToFavorites(this._post, this._signedInUser.id);
    } else {
      await Provider.of<ContentItems>(context, listen: false)
          .removeFromFavorites(this._post, this._signedInUser.id);
    }
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

  void _setIsFavorite() {
    setState(() {
      this._isFavorite =
          this._post.likes.any((l) => l == this._signedInUser.id);
    });
  }

  void _submitComment() {
    if(this._input.text.isEmpty) return;

  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context).settings.arguments as dynamic;
    this._post = Provider.of<ContentItems>(context)
        .getContentById(args['contentItemId']);
    this._signedInUser = Provider.of<Users>(context).signedInUser;
    final user = Provider.of<Users>(context).findById(this._post.userId);
    this._setIsFavorite();
    return Scaffold(
      appBar: AppBar(
        title: Text(this._post.title),
        actions: <Widget>[
          CircleAvatarButton(user, Theme.of(context).primaryColor, true),
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
                                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
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
                  icon: Icon(this._isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border),
                  onPressed: () {
                    this._toggleFavorite().then((_) {
                      this._setIsFavorite();
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(DateFormat('dd.MM.yyyy').format(this._post.timestamp),
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: Text(this._post.description, style: TextStyle(
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
                  child: Column(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: this
                            ._post
                            .comments
                            .map((Comment c) => CommentWidget(c))
                            .toList(),
                      ),
                      TextField(
                        controller: _input,
                        onSubmitted: (_) => this._submitComment(),
                        decoration: new InputDecoration(
                            hintText: 'Add comment...',
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(2),
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: ClipOval(
                                  child: Image.network(
                                    this._signedInUser.avatarUrl,
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
                                setState(() {
                                  this._input.clear();
                                });
                              },
                            )
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ), //
    );
  }
}
