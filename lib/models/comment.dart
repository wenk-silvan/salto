import 'dart:convert';

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

  static Comment copy(Comment comment, id) {
    return Comment(
      id: id,
      text: comment.text,
      timestamp: comment.timestamp,
      userId: comment.userId,
    );
  }

  static Comment fromJson(id, data) {
    return Comment(
      id: id,
      text: data['text'],
      timestamp: DateTime.parse(data['timestamp']),
      userId: data['userId'],
    );
  }

  static String toJson(Comment comment) {
    return json.encode({
      'text': comment.text,
      'timestamp': comment.timestamp.toIso8601String(),
      'userId': comment.userId,
    });
  }
}
