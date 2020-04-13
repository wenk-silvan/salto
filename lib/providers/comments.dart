import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:salto/models/comment.dart';
import 'package:http/http.dart' as http;
import 'package:salto/models/http_exception.dart';

class Comments with ChangeNotifier {
  static const url = "https://salto-7fab8.firebaseio.com";
  String authString;
  final String authToken;
  List<Comment> _items;

  Comments(this.authToken, this._items) {
    this.authString = '?auth=$authToken';
  }

  List<Comment> get items {
    return this._items;
  }

  Future<void> getComments(String contentItemId) async {
    try {
      if (this.authToken == null) return;
      final response =
      await http.get('$url/comments/$contentItemId.json$authString');
      final List<Comment> loadedComments = [];
      final extracted = json.decode(response.body) as Map<String, dynamic>;
      if (extracted == null) {
        this._items = [];
        return;
      }

      if (response.statusCode >= 400 || response.statusCode >= 400) {
        throw new HttpException('Failed to post comment.');
      }

      extracted
          .forEach((id, data) => loadedComments.add(Comment.fromJson(id, data)));
      this._items = loadedComments.toList();
      print("Loaded comments for post with id: $contentItemId.");
      //this.notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addComment(Comment comment, String contentItemId) async {
    try {
      if (contentItemId == null || contentItemId.isEmpty) return;
      final body = Comment.toJson(comment);
      final response =
      await http.post('$url/comments/$contentItemId.json$authString', body: body);
      this._items.add(Comment.copy(comment, json.decode(response.body)['name']));

      if (response.statusCode >= 400 || response.statusCode >= 400) {
        throw new HttpException('Failed to post comment.');
      }
      print("Added comment to post with id: $contentItemId.");
      this.notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}