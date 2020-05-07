import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:salto/models/http_exception.dart';

class ContentItem {
  final String id;
  final String title;
  final String description;
  final String mediaUrl;
  final DateTime timestamp;
  final String userId;
  final List<String> likes;

  const ContentItem({
    @required this.id,
    @required this.title,
    this.description,
    @required this.mediaUrl,
    this.timestamp,
    @required this.userId,
    @required this.likes,
  });

  static ContentItem copy(ContentItem item, itemId) {
    return ContentItem(
      id: itemId,
      likes: item.likes,
      userId: item.userId,
      title: item.title,
      mediaUrl: item.mediaUrl,
      timestamp: item.timestamp,
      description: item.description,
    );
  }

  static ContentItem fromJson(contentItemId, contentItemData) {
    if (contentItemData['mediaUrl'] == null || contentItemData['title'] == null || contentItemData['userId'] == null) {
      throw HttpException('The ContentItem is missing some data and can not be deserialized. [ID=$contentItemId, Data=$contentItemData]');
    }
    return ContentItem(
      id: contentItemId,
      mediaUrl: contentItemData['mediaUrl'],
      title: contentItemData['title'],
      userId: contentItemData['userId'],
      timestamp: DateTime.parse(contentItemData['dateTime']),
      description: contentItemData['description'],
      likes: contentItemData['likes'] == null
          ? []
          : (contentItemData['likes'] as List<dynamic>)
          .map((userId) => userId.toString())
          .toList(),
    );
  }

  static isFavorite(ContentItem post, userId) {
    return post.likes.any((l) => l == userId);
  }

  static String toJson(ContentItem item) {
    final timestamp = DateTime.now();
    return json.encode({
      'title': item.title,
      'description': item.description,
      'mediaUrl': item.mediaUrl,
      'dateTime': timestamp.toIso8601String(),
      'userId': item.userId,
      'likes': item.likes
    });
  }
}
