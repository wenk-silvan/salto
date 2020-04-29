import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salto/components/timestamp.dart';
import 'package:salto/models/comment.dart';
import 'package:salto/providers/users.dart';

class CommentWidget extends StatefulWidget {
  final Comment comment;

  CommentWidget(this.comment);

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<Users>(context, listen: false)
        .findById(widget.comment.userId);
    if (user == null) return SizedBox(); // TODO: Fix workaround if comment structure updated and comments get deleted when user profile gets deleted.
    var currentTextData = StringBuffer();
    var textSpans = <TextSpan>[
      TextSpan(
          text: '@${user.userName}',
          style: TextStyle(fontWeight: FontWeight.bold)),
    ];

    currentTextData.write(' ');
    currentTextData.write(this.widget.comment.text);
    if (currentTextData.isNotEmpty) {
      textSpans.add(TextSpan(text: currentTextData.toString()));
      currentTextData.clear();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text.rich(TextSpan(children: textSpans)),
          Timestamp(this.widget.comment.timestamp),
        ],
      ),
    );
  }
}
