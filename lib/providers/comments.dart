import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:salto/models/comment.dart';
import 'package:http/http.dart' as http;
import 'package:salto/models/content-item.dart';
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

  void trigger() {
    this.notifyListeners();
  }

  Future<void> getComments(String contentItemId) async {
    try {
      if (this.authToken == null) return;
      final response =
          await http.get('$url/comments/$contentItemId.json$authString');
      final responseBody = json.decode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 400) {
        print(responseBody['error']);
        throw new HttpException('Could not fetch comments.');
      }
      final List<Comment> loadedComments = [];
      if (responseBody == null) {
        this._items = [];
        return;
      }
      responseBody.forEach(
          (id, data) => loadedComments.add(Comment.fromJson(id, data)));
      this._items = loadedComments.toList();
      print("Loaded comments for post with id: $contentItemId.");
    } on SocketException catch (_) {
      throw HttpException('No network connection.');
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> addComment(Comment comment, String contentItemId) async {
    try {
      if (contentItemId == null || contentItemId.isEmpty) return;
      this._items.add(Comment.copy(comment, ''));
      this.notifyListeners();
      final body = Comment.toJson(comment);
      final response = await http
          .post('$url/comments/$contentItemId.json$authString', body: body);
      if (response.statusCode >= 400) {
        print(json.decode(response.body)['error']);
        throw new HttpException('Could not add comment.');
      }
      print('Added comment to post with id: $contentItemId.');
    } on SocketException catch (_) {
      throw HttpException('No network connection.');
    } catch (error) {
      throw error;
    }
  }

  Future<void> deleteCommentsOfUser(
      String userId, List<ContentItem> posts) async {
    try {
      posts.forEach((post) {
        //TODO: Rethink design of comments (especially deleting).
      });
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> deleteComment(String id, String postId) async {
    try {
      final response =
          await http.delete('$url/comments/$postId/$id.json$authString');
      if (response.statusCode >= 400) {
        print(json.decode(response.body)['error'] +
            ' [id=$id;postId=$postId]');
        throw HttpException("Could not delete comment.");
      }
      this._items.removeWhere((i) => i.id == id);
      this.notifyListeners();
    } on SocketException catch (_) {
      throw HttpException('No network connection.');
    } catch (error) {
      print(error);
      throw error;
    }
  }
}
