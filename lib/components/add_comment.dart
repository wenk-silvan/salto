import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salto/models/comment.dart';
import 'package:salto/providers/comments.dart';
import 'package:salto/models/http_exception.dart';

class AddComment extends StatelessWidget {
  final TextEditingController _input = new TextEditingController();
  String userId;
  String postId;

  AddComment({this.userId, this.postId});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _input,
      style: TextStyle(fontSize: 15),
      onSubmitted: (_) => this._submitComment,
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
  }

  void _submitComment(BuildContext ctx) async {
    if (this._input.text.isEmpty) return;
    try {
      await Provider.of<Comments>(ctx).addComment(
          Comment(
            userId: this.userId,
            timestamp: DateTime.now(),
            text: this._input.text,
            id: '',
          ),
          this.postId);
    } on HttpException catch (error) {
      HttpException.showErrorDialog(error.toString(), ctx);
    }
  }
}
