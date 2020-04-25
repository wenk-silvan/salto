import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salto/components/add_comment.dart';
import 'package:salto/components/circle_avatar_button.dart';
import 'package:salto/components/comment_widget.dart';
import 'package:salto/models/comment.dart';
import 'package:salto/models/user.dart';
import 'package:salto/providers/comments.dart';

class CommentScreen extends StatelessWidget {
  final TextEditingController _input = new TextEditingController();
  static const route = '/comments';
  List<Comment> _comments;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context).settings.arguments as dynamic;
    final postId = args['postId'];
    final User user = args['user'];
    return Scaffold(
      appBar: AppBar(
        title: Text("${user.firstName} ${user.lastName}"),
        actions: <Widget>[
          CircleAvatarButton(user, Theme.of(context).primaryColor)
        ],
      ),
      body: Card(
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FutureBuilder(
                future: Provider.of<Comments>(context, listen: false)
                    .getComments(postId),
                builder: (ctx, authResultSnapshot) {
                  if (authResultSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    this._comments =
                        Provider.of<Comments>(context, listen: false).items;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        this._comments.length > 0
                            ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: this
                                ._comments
                                .map((Comment c) => CommentWidget(c))
                                .toList())
                            : Text('No comments available.'),
                        AddComment(userId: user.id, postId: postId),
                      ],
                    );
                  }
                })),
      ),
    );
  }
}
