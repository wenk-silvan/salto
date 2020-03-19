import 'dart:convert';

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
  final List<String> likes;

  const ContentItem({
    @required this.id,
    @required this.title,
    this.description,
    @required this.mediaUrl,
    this.timestamp,
    @required this.userId,
    @required this.comments,
    @required this.likes,
  });

  static ContentItem fromJson(contentItemId, contentItemData) {
    return ContentItem(
      id: contentItemId,
      mediaUrl: contentItemData['mediaUrl'],
      title: contentItemData['title'],
      userId: contentItemData['userId'],
      timestamp: DateTime.parse(contentItemData['dateTime']),
      description: contentItemData['description'],
      comments: contentItemData['comments'] == null
          ? []
          : (contentItemData['comments'] as List<dynamic>)
          .map((comment) => Comment(
        timestamp: DateTime.parse(comment['timestamp']),
        userId: comment['userId'],
        id: comment['id'],
        text: comment['text'],
      ))
          .toList(),
      likes: contentItemData['likes'] == null
          ? []
          : (contentItemData['likes'] as List<dynamic>)
          .map((userId) => userId.toString())
          .toList(),
    );
  }

  static String toJson(ContentItem item) {
    final timestamp = DateTime.now();
    return json.encode({
      'title': item.title,
      'description': item.description,
      'mediaUrl': item.mediaUrl,
      'dateTime': timestamp.toIso8601String(),
      'userId': item.userId,
      'comments': item.comments
          .map((c) => {
        'id': c.id,
        'userId': c.userId,
        'timestamp': c.timestamp.toIso8601String(),
        'text': c.text,
      })
          .toList(),
      'likes': item.likes
    });
  }
}
