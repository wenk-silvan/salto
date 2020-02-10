import 'package:flutter/material.dart';

import 'comment.dart';
import 'like.dart';
import 'user.dart';

class ContentItem {
  final String contentId; // count starts at 50
  final String title;
  final String description;
  final String mediaUrl;
  final DateTime timestamp;
  final User owner;
  final List<Comment> comments;
  final int likeCount;
  final List<Like> likes;

  ContentItem({
    @required this.contentId,
    @required this.title,
    this.description,
    @required this.mediaUrl,
    @required this.timestamp,
    @required this.owner,
    @required this.comments,
    @required this.likeCount,
    @required this.likes,
  });

  bool isLikedBy(User user) {
    return likes.any((like) => user.userName == like.user.userName);
  }
}
