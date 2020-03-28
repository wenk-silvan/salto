import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:salto/models/http_exception.dart';

import '../models/user.dart';
import 'package:http/http.dart' as http;

class Users with ChangeNotifier {
  static const url = "https://salto-7fab8.firebaseio.com";
  String authString;
  final String authToken;
  List<User> _users = [];

  User signedInUser;

  Users(this.authToken, this._users) {
    if (this.authToken == null) return;
    this.authString = '?auth=$authToken';
  }

  List<User> get users {
    return this._users;
  }

  User findById(String userId) {
    if (this._users == null) return null;
    return this._users.firstWhere((u) => u.id == userId);
  }

  Future<void> getUsers() async {
    final response = await http.get('$url/users.json$authString');
    final List<User> loadedUsers = [];
    final extracted = json.decode(response.body) as Map<String, dynamic>;
    if (extracted == null) return;
    extracted.forEach((id, data) => loadedUsers.add(User.fromJson(id, data)));
    this._users = loadedUsers.toList();
    print("Loaded users from database.");
    this.notifyListeners();
  }

  bool login(String uuid) {
    this.signedInUser = this
        ._users
        .firstWhere((u) => u.uuid == uuid, orElse: () => null);
    if (this.signedInUser == null) return false;
    print('Logged in user: ${this.signedInUser.userName} - uuid: $uuid');
    return true;
  }

  List<User> findByName(String text) {
    return this._users.where((u) {
      var lowerCaseText = text.toLowerCase();
      return u.firstName.toLowerCase().contains(lowerCaseText) ||
          u.lastName.toLowerCase().contains(lowerCaseText) ||
          u.userName.toLowerCase().contains(lowerCaseText);
    }).toList();
  }

  bool follows(String userId) {
    return this.signedInUser.follows.any((f) => f == userId);
  }

  Future<void> toggleFollowingStatus(User user) async {
    var follows = this.signedInUser.follows;
    var followers = user.followers;

    if (follows.any((f) => f == user.id)) {
      //Remove
      follows.remove(user.id);
      followers.remove(this.signedInUser.id);
    } else {
      //Add
      follows.add(user.id);
      followers.add(this.signedInUser.id);
    }

    try {
      final statusCodeFollowers =
          await this._updateFollowers(user.id, followers);
      final statusCodeFollows = await this._updateFollows(follows);
      if (statusCodeFollowers >= 400 || statusCodeFollows >= 400) {
        throw new HttpException('Failed to toggle following status.');
      }
      this.notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> removeSignedInUser() async {
    try {
      final response =
      await http.delete('$url/users/${this.signedInUser.id}.json$authString');
      if(response.statusCode >= 400) {
        throw new HttpException('Failed to remove data from user.');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<int> _updateFollowers(String userId, List<String> followers) async {
    final body = json.encode({
      'followers': followers,
    });
    try {
      final response =
          await http.patch('$url/users/$userId.json$authString', body: body);
      if (response.statusCode >= 400 || response.statusCode >= 400) {
        throw new HttpException('Failed to toggle following status.');
      }
      return response.statusCode;
    } catch (error) {
      throw error;
    }
  }

  Future<int> _updateFollows(List<String> follows) async {
    final body = json.encode({
      'follows': follows,
    });
    try {
      final response = await http.patch(
          '$url/users/${this.signedInUser.id}.json$authString',
          body: body);
      return response.statusCode;
    } catch (error) {
      throw error;
    }
  }
}
