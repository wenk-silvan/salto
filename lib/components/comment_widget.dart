import 'package:flutter/material.dart';
import 'package:salto/models/comment.dart';

class CommentWidget extends StatefulWidget {
  final Comment comment;

  CommentWidget(this.comment);

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  @override
  Widget build(BuildContext context) {
    var currentTextData = StringBuffer();
    var textSpans = <TextSpan>[
      TextSpan(
          text: '${widget.comment.owner.userName}',
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
        child: Text.rich(TextSpan(children: textSpans)));
  }
}
