import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:salto/models/user.dart';

import '../models/content-item.dart';
import 'package:http/http.dart' as http;

class ContentItems with ChangeNotifier {
  static const url = "https://salto-7fab8.firebaseio.com/";
  List<String> _favoriteUserIds = [];
  List<ContentItem> _items = [];

  List<ContentItem> get items {
    return this._items;
  }

  List<ContentItem> get favItems {
    return this.getContentOfUsers(this._favoriteUserIds);
  }

  Future<void> addContent(ContentItem item) async {
    final body = ContentItem.toJson(item);
    final response = await http.post(url + "content.json", body: body);
    this.items.add(ContentItem(
          id: json.decode(response.body)['name'],
          likes: item.likes,
          userId: item.userId,
          comments: item.comments,
          title: item.title,
          mediaUrl: item.mediaUrl,
          timestamp: item.timestamp,
          description: item.description,
        ));
    this.notifyListeners();
  }

  Future<void> addToFavorites(ContentItem post, String userId) async {
    post.likes.add(userId);
    try {
      final statusCode = await this._updateLikesOfPost(post.likes, post.id);
      if (statusCode >= 400) {
        print("Error while adding like.");
        post.likes.remove(userId);
      }
      this.notifyListeners();
    } catch (error) {
      print(error);
      post.likes.remove(userId);
      this.notifyListeners();
    }
  }

  List<ContentItem> findByTitle(String text) {
    return this
        ._items
        .where((i) => i.title.toLowerCase().contains(text.toLowerCase()))
        .toList();
  }

  Future<void> getContent(User signedInUser) async {
    this._favoriteUserIds = signedInUser.follows;
    final response = await http.get(url + 'content.json');
    final List<ContentItem> loadedContent = [];
    final extracted = json.decode(response.body) as Map<String, dynamic>;
    if (extracted == null) return;
    extracted.forEach(
        (id, data) => loadedContent.add(ContentItem.fromJson(id, data)));
    this._items = loadedContent.toList();
    print("Loaded content from database.");
    this.notifyListeners();
  }

  List<String> getContentByUserId(String userId) {
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

  Future<void> removeFromFavorites(ContentItem post, String userId) async {
    post.likes.remove(userId);
    try {
      final statusCode = await this._updateLikesOfPost(post.likes, post.id);
      if (statusCode >= 400) {
        print("Error while removing like.");
        post.likes.add(userId);
      }
      this.notifyListeners();
    } catch (error) {
      print(error);
      post.likes.add(userId);
      this.notifyListeners();
    }
  }

  Future<int> _updateLikesOfPost(List<String> likes, String postId) async {
    final body = json.encode({
      'likes': likes,
    });
    try {
      final response =
          await http.patch(url + "/content/$postId.json", body: body);
      return response.statusCode;
    } catch (error) {
      throw error;
    }
  }
}
