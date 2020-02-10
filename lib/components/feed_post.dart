import 'package:flutter/material.dart';
import 'package:salto/models.dart';
import 'package:salto/screens/profile_screen.dart';
import 'package:salto/components/comment_widget.dart';

class FeedPost extends StatefulWidget {
  final ContentItem post;

  FeedPost(this.post);

  @override
  _FeedPostState createState() => _FeedPostState();
}

class _FeedPostState extends State<FeedPost> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                //Avatar
                GestureDetector(
                    child: new Padding(
                        padding: const EdgeInsets.only(
                            left: 5.0, right: 10.0, top: 5.0, bottom: 10.0),
                        child: CircleAvatar(
                            child: ClipOval(
                          // Avatar image recieved by db
                          //TODO: query User.avatarUrl WHERE User.uuid = ContentItem.uuid
                          child: Image.network(
                              'https://upload.wikimedia.org/wikipedia/commons/c/c5/A.J.M._Arkor.jpg'),
                        ))),
                    onTap: () =>
                        Navigator.of(context).pushNamed(ProfileScreen.route)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(widget.post.title,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            Image.network(widget.post.mediaUrl),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.favorite_border),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.comment),
                )
              ],
            ),
            // ContentId Description
            Padding(
              padding: EdgeInsets.only(right: 8.0, left: 8.0, bottom: 6.0),
              child: Text(widget.post.description),
              /*child: Text.rich(
                TextSpan(
                  children: <TextSpan>[
                      TextSpan(
                        text: 'User ${widget.post.ownerUuid} ',
                        style: TextStyle(fontWeight: FontWeight.bold)
                      ),
                      TextSpan(
                        text: '${widget.post.description}',
                      )
                    ],
                ),
              ),*/
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
