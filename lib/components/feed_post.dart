import 'package:flutter/material.dart';
import 'package:salto/models.dart';
import 'package:salto/screens/profile_screen.dart';

class FeedPost extends StatefulWidget {
  final ContentItem post;

  FeedPost(this.post);
  @override
  _FeedPostState createState() => _FeedPostState();
}

class _FeedPostState extends State<FeedPost> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            //Avatar
            GestureDetector(
                child: new Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: CircleAvatar(
                        child: ClipOval(
                          // Avatar image recieved by db
                          //TODO: query User.avatarUrl WHERE User.uuid = ContentItem.uuid
                          child: Image.network('https://upload.wikimedia.org/wikipedia/commons/c/c5/A.J.M._Arkor.jpg'),
                        )
                    )
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileScreen())
                  );
                }
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(widget.post.title, style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        Image.network(widget.post.mediaUrl),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.favorite),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.comment),
            )
          ],
        ),
        Text('01-01-2020'), // TODO: calculate & print timestamp
      ],
    );//
  }
}