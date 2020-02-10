import 'package:flutter/material.dart';
import 'user.dart';

class Comment {
  final String id; // count starts at 100
  final String text;
  final String userId;
  final DateTime timestamp;

  const Comment({
    @required this.id,
    @required this.text,
    @required this.userId,
    @required this.timestamp,
  });
}
