import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salto/components/timestamp.dart';
import 'package:salto/models/comment.dart';
import 'package:salto/providers/users.dart';

class CommentWidget extends StatelessWidget {
  final Comment comment;

  CommentWidget(this.comment);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<Users>(context, listen: false)
        .findById(this.comment.userId);
    if (user == null)
      return SizedBox(); // TODO: Fix workaround if comment structure updated and comments get deleted when user profile gets deleted.
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            '@${user.userName}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 5),
          Text(this.comment.text),
          Spacer(),
          Timestamp(this.comment.timestamp),
        ],
      ),
    );
  }
}
