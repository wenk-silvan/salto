import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salto/models/comment.dart';
import 'package:salto/providers/comments.dart';
import 'package:salto/models/http_exception.dart';

class AddComment extends StatefulWidget {
  String userId;
  String postId;
  bool hasLine;

  AddComment({this.userId, this.postId, this.hasLine});

  @override
  _AddCommentState createState() => _AddCommentState();
}

class _AddCommentState extends State<AddComment> {
  final TextEditingController _input = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (this.widget.hasLine) {
      return TextField(
        controller: _input,
        style: TextStyle(fontSize: 15),
        onSubmitted: (_) => this._submitComment(context),
        decoration: new InputDecoration(
            hintText: 'Add comment...',
            suffixIcon: IconButton(
              icon: Icon(Icons.keyboard_arrow_right),
              onPressed: () {
                this._submitComment(context);
                this._input.clear();
              },
            )),
      );
    } else {
      return TextField(
        controller: _input,
        style: TextStyle(fontSize: 15),
        onSubmitted: (_) => this._submitComment(context),
        decoration: new InputDecoration(
            hintText: 'Add comment...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: Icon(Icons.keyboard_arrow_right),
              onPressed: () {
                this._submitComment(context);
                this._input.clear();
              },
            )),
      );
    }
  }

  void _submitComment(BuildContext ctx) async {
    if (this._input.text.isEmpty) {
      Scaffold.of(ctx).showSnackBar(SnackBar(
          content: Text('Can\'t add empty comment')
      ));
      return;
    }
    try {
      await Provider.of<Comments>(ctx).addComment(
          Comment(
            userId: this.widget.userId,
            timestamp: DateTime.now(),
            text: this._input.text,
            id: '',
          ),
          this.widget.postId);
    } on HttpException catch (error) {
      HttpException.showErrorDialog(error.message, ctx);
    }
  }
}
