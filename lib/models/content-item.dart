import 'package:flutter/material.dart';

import 'comment.dart';

class ContentItem {
  final String id; // count starts at 50
  final String title;
  final String description;
  final String mediaUrl;
  final DateTime timestamp;
  final String userId;
  final List<Comment> comments;
  final int likeCount;
  final List<String> likes;

  const ContentItem({
    @required this.id,
    @required this.title,
    this.description,
    @required this.mediaUrl,
    this.timestamp,
    @required this.userId,
    @required this.comments,
    @required this.likeCount,
    @required this.likes,
  });

  /*bool isLikedBy(User user) {
    return likes.any((like) => user.userName == like.user.userName);
  }*/
}
