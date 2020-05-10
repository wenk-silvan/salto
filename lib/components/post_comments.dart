import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salto/models/comment.dart';
import 'package:salto/models/content-item.dart';
import 'package:salto/providers/comments.dart';
import 'package:salto/screens/comments_screen.dart';
import 'package:salto/models/http_exception.dart';

import 'comment_widget.dart';

class PostComments extends StatelessWidget {
  final ContentItem post;
  final Map<String, dynamic> commentScreenArguments;
  List<Comment> _comments = [];

  PostComments(this.post, this.commentScreenArguments);

  @override
  Widget build(BuildContext context) {
    return _comments.length < 1
        ? FutureBuilder(
            future: _getCommentsFuture(context),
            builder: (ctx, authResultSnapshot) {
              if (authResultSnapshot.connectionState == ConnectionState.done) {
                _comments = Provider.of<Comments>(context, listen: false).items;
                return _commentsListBuilder(ctx);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            })
        : _commentsListBuilder(context);
  }

  Widget _commentsListBuilder(BuildContext ctx) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _comments.length < 1
              ? const Text('No comments available.')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _comments.length < 4
                      ? _comments.map((Comment c) => CommentWidget(c)).toList()
                      : _comments
                          .getRange(_comments.length - 3, _comments.length)
                          .map((Comment c) => CommentWidget(c))
                          .toList()),
          _comments.length > 3
              ? InkWell(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'more',
                        style: TextStyle(color: Theme.of(ctx).accentColor),
                      ),
                    ],
                  ),
                  onTap: () => Navigator.of(ctx).pushNamed(CommentsScreen.route,
                      arguments: this.commentScreenArguments),
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  Future<void> _getCommentsFuture(BuildContext ctx) async {
    try {
      return await Provider.of<Comments>(ctx).getComments(this.post.id);
    } on HttpException catch (error) {
      HttpException.showErrorDialog(error.message, ctx);
      return null;
    }
  }
}
