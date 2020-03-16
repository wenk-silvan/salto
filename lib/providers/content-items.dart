import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:salto/models/user.dart';
import 'package:salto/providers/users.dart';

import '../models/comment.dart';
import '../models/content-item.dart';
import 'package:http/http.dart' as http;

class ContentItems with ChangeNotifier {
  static const url = "https://salto-7fab8.firebaseio.com/";
   List<String> _favoriteUserIds = [];

  List<ContentItem> _favItems = [];
  List<ContentItem> _items = [];

  List<ContentItem> get items {
    return this._items;
  }

  List<ContentItem> get favItems {
    return this.getContentOfUsers(this._favoriteUserIds);
  }

  Future<void> addContent(ContentItem item) async {
    final timestamp = DateTime.now();
    final body = json.encode({
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
          }).toList(),
      'likes': item.likes
    });
    final response = await http.post(
      url + "/content.json",
      body: body
    );
    this.notifyListeners();
  }

  Future<void> getContent(User user) async {
    this._favoriteUserIds = user.follows;
    final response = await http.get(url + 'content.json');
    final List<ContentItem> loadedContent = [];
    final extracted = json.decode(response.body) as Map<String, dynamic>;
    if (extracted == null) return;
    extracted.forEach((contentId, contentData) {
      loadedContent.add(ContentItem(
        id: contentId,
        mediaUrl: contentData['mediaUrl'],
        title: contentData['title'],
        userId: contentData['userId'],
        timestamp: DateTime.parse(contentData['dateTime']),
        description: contentData['description'],
        comments: (contentData['comments'] as List<dynamic>).map((comment) => Comment(
          timestamp: DateTime.parse(comment['timestamp']),
          userId: comment['userId'],
          id: comment['id'],
          text: comment['text'],
        )).toList(),
        likes: (contentData['likes'] as List<dynamic>).map((userId) => userId.toString()).toList(),
      ));
    });
    this._items = loadedContent.toList();
    print("Loaded content from database.");
    this.notifyListeners();
  }

  List<String> getMediaByUserId(String userId) {
    return this
        ._items
        .where((i) => i.userId == userId)
        .map((i) => i.mediaUrl)
        .toList();
  }

  List<ContentItem> getContentOfUsers(List<String> userIds) {
    List<ContentItem> items = [];
    userIds.forEach(
        (id) => items.addAll(this._items.where((i) => i.userId == id)));
    return items;
  }
}
