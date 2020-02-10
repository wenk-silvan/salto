import 'package:flutter/material.dart';
import 'user.dart';

class Comment {
  final String commentId; // count starts at 100
  final String text;
  final User owner;
  final DateTime timestamp;

  Comment({
    @required this.commentId,
    @required this.text,
    @required this.owner,
    @required this.timestamp,
  });
}
