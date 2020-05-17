import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:salto/models/http_exception.dart';
import 'package:salto/models/user.dart';
import 'package:salto/providers/storage.dart';

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
    final errorMsg = 'Could not add new post.';
    try {
      final body = ContentItem.toJson(item);
      final response =
          await http.post('$url/content.json$authString', body: body);
      final responseBody = json.decode(response.body);
      if (response.statusCode >= 400) {
        print(responseBody['error']);
        throw HttpException(errorMsg);
      }
      final postId = responseBody['name'];
      if (postId == null) throw HttpException(errorMsg);
      return postId;
    } on SocketException catch (_) {
      throw HttpException('No network connection.');
    } catch (error) {
      print(error);
      throw error;
    }
  }

  void addFirst(ContentItem item) {
    _items.insert(0, item);
  }

  Future<void> addToFavorites(ContentItem post, String userId) async {
    post.likes.add(userId);
    this.notifyListeners();
    try {
      await this.updatePost({'likes': post.likes}, post.id);
    } catch (error) {
      print(error);
      post.likes.remove(userId);
      this.notifyListeners();
      throw error;
    }
  }

  Future<void> deleteContent(Storage storageProvider, String postId) async {
    try {
      var copy = _items.sublist(0, _items.length);
      copy.removeWhere((i) => i.id == postId);
      _items = copy.sublist(0, copy.length);
      this.notifyListeners();
      final response =
          await http.delete('$url/content/$postId.json$authString');
      if (response.statusCode >= 400) {
        print(json.decode(response.body)['error']);
        throw HttpException('Could not delete post.');
      }
      storageProvider.deleteFromStorage('videos', '$postId.mp4');
    } on SocketException catch (_) {
      throw HttpException('No network connection.');
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> deleteContentOfUser(
      Storage storageProvider, String userId) async {
    try {
      _items
          .where((i) => i.likes.any((l) => l == userId))
          .forEach((i) => this.removeFromFavorites(i, userId));
      _items
          .where((i) => i.userId == userId)
          .forEach((i) => deleteContent(storageProvider, i.id));
    } catch (error) {
      print(error);
      throw error;
    }
  }

  List<ContentItem> findByTitle(String text) {
    return this
        ._items
        .where((i) => i.title.toLowerCase().contains(text.toLowerCase()))
        .toList();
  }

  Future<void> getContent(User signedInUser) async {
    try {
      this._favoriteUserIds = signedInUser.follows;
      final response = await http.get('$url/content.json$authString');
      if (response.statusCode >= 400) {
        print(json.decode(response.body)['error']);
        throw HttpException('Could not fetch content.');
      }
      final List<ContentItem> loadedContent = [];
      final extracted = json.decode(response.body) as Map<String, dynamic>;
      if (extracted == null) return;
      extracted.forEach(
          (id, data) => loadedContent.add(ContentItem.fromJson(id, data)));
      loadedContent.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      this._items = loadedContent.toList();
      this.notifyListeners();
    } on SocketException catch (_) {
      throw HttpException('No network connection.');
    } catch (error) {
      print(error);
      throw error;
    }
  }

  ContentItem getContentById(String id) {
    return this._items.firstWhere((i) => i.id == id, orElse: null);
  }

  List<ContentItem> getContentByUserId(String userId) {
    return this._items.where((i) => i.userId == userId).toList();
  }

  List<ContentItem> getContentOfUsers(List<String> userIds) {
    List<ContentItem> items = [];
    userIds.forEach(
        (id) => items.addAll(this._items.where((i) => i.userId == id)));
    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return items;
  }

  Future<void> removeFromFavorites(ContentItem post, String userId) async {
    try {
      post.likes.remove(userId);
      this.notifyListeners();
      await this.updatePost({'likes': post.likes}, post.id);
    } catch (error) {
      print(error);
      post.likes.add(userId);
      this.notifyListeners();
      throw error;
    }
  }

  Future<void> toggleFavorites(ContentItem post, userId) async {
    try {
      if (ContentItem.isFavorite(post, userId)) {
        return await this.removeFromFavorites(post, userId);
      } else {
        return await this.addToFavorites(post, userId);
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> updatePost(Map<String, dynamic> data, String postId) async {
    final body = json.encode(data);
    try {
      final response =
          await http.patch('$url/content/$postId.json$authString', body: body);
      if (response.statusCode >= 400) {
        print(json.decode(response.body)['error']);
        throw HttpException('Could not update post.');
      }
    } on SocketException catch (_) {
      throw HttpException('No network connection.');
    } catch (error) {
      print(error);
      throw error;
    }
  }
}
