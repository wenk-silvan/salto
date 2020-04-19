import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:salto/models/http_exception.dart';
import 'package:salto/models/user.dart';

import '../models/content-item.dart';
import 'package:http/http.dart' as http;

class ContentItems with ChangeNotifier {
  static const url = "https://salto-7fab8.firebaseio.com";
  String authString;
  final String authToken;
  List<String> _favoriteUserIds = [];
  List<ContentItem> _items = [];

  ContentItems(this.authToken, this._items) {
    this.authString = '?auth=$authToken';
  }

  List<ContentItem> get items {
    return this._items;
  }

  List<ContentItem> get favItems {
    return this.getContentOfUsers(this._favoriteUserIds);
  }

  Future<String> addContent(ContentItem item) async {
    final body = ContentItem.toJson(item);
    final response =
        await http.post('$url/content.json$authString', body: body);
    final contentItemId = json.decode(response.body)['name'];
    this.items.add(ContentItem.copy(item, contentItemId));
    this.notifyListeners();
    return contentItemId;
  }

  Future<void> addToFavorites(ContentItem post, String userId) async {
    post.likes.add(userId);
    try {
      final statusCode = await this.updatePost('likes', post.likes, post.id);
      if (statusCode >= 400) {
        print("Error while adding like.");
        post.likes.remove(userId);
      }
    } catch (error) {
      print(error);
      post.likes.remove(userId);
    }
  }

  Future<void> deleteContent(String postId) async {
    try {
      final response = await http.delete('$url/content/$postId.json$authString');
      if (response.statusCode >= 400) {
        throw HttpException("Error while deleting post.");
      }
    } catch (error) {
      print(error);
      throw HttpException("Error while deleting post.");
    }
    this.notifyListeners();

  }

  List<ContentItem> findByTitle(String text) {
    return this
        ._items
        .where((i) => i.title.toLowerCase().contains(text.toLowerCase()))
        .toList();
  }

  Future<void> getContent(User signedInUser) async {
    this._favoriteUserIds = signedInUser.follows;
    final response = await http.get('$url/content.json$authString');
    final List<ContentItem> loadedContent = [];
    final extracted = json.decode(response.body) as Map<String, dynamic>;
    if (extracted == null) return;
    extracted.forEach(
        (id, data) => loadedContent.add(ContentItem.fromJson(id, data)));
    loadedContent.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    this._items = loadedContent.toList();
    print("Loaded content from database.");
    this.notifyListeners();
  }

  ContentItem getContentById(String id) {
    return this._items.firstWhere((i) => i.id == id, orElse: null);
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
    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return items;
  }

  Future<void> removeFromFavorites(ContentItem post, String userId) async {
    post.likes.remove(userId);
    try {
      final statusCode = await this.updatePost('likes', post.likes, post.id);
      if (statusCode >= 400) {
        print("Error while removing like.");
        post.likes.add(userId);
      }
    } catch (error) {
      print(error);
      post.likes.add(userId);
    }
  }

  Future<void> toggleFavorites(ContentItem post, userId) async {
    if (ContentItem.isFavorite(post, userId)) {
      await this.removeFromFavorites(post, userId);
    } else {
      await this.addToFavorites(post, userId);
    }
  }

  Future<int> updatePost(String field, dynamic data, String postId) async {
    final body = json.encode({
      field: data,
    });
    try {
      final response =
          await http.patch('$url/content/$postId.json$authString', body: body);
      return response.statusCode;
    } catch (error) {
      throw error;
    }
  }
}
