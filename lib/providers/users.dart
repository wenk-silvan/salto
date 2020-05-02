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
    final users = this._users.where((u) => u.id == userId).toList();
    return users.length > 0 ? users.first : null;
  }

  Future<void> getUsers() async {
    final errorMsg = 'Failed to fetch users.';
    try {
      final response = await http.get('$url/users.json$authString');
      if(response.statusCode >= 400) {
        throw new HttpException(errorMsg);
      }
      final List<User> loadedUsers = [];
      final extracted = json.decode(response.body) as Map<String, dynamic>;
      if (extracted == null) return;
      extracted.forEach((id, data) => loadedUsers.add(User.fromJson(id, data)));
      this._users = loadedUsers.toList();
      this.notifyListeners();
    } catch (error) {
      print(error);
      throw new HttpException(errorMsg);
    }
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
    this.notifyListeners();
    final errorMsg = 'Failed to toggle following status';
    try {
      final statusCodeFollowers =
          await this._updateFollowers(user.id, followers);
      final statusCodeFollows = await this._updateFollows(this.signedInUser.id, follows);
      if (statusCodeFollowers >= 400 || statusCodeFollows >= 400) {
        throw new HttpException(errorMsg);
      }
    } catch (error) {
      print(error);
      throw HttpException(errorMsg);
    }
  }

  Future<void> removeSignedInUser() async {
    try {
      this.signedInUser.follows.forEach((userId) {
        final newFollowers = _users.firstWhere((u) => u.id == userId).followers;
        newFollowers.remove(signedInUser.id);
        _updateFollowers(userId, newFollowers);
      });
      this.signedInUser.followers.forEach((userId) {
        final newFollows = _users.firstWhere((u) => u.id == userId).follows;
        newFollows.remove(signedInUser.id);
        _updateFollows(userId, newFollows);
      });
      final response =
      await http.delete('$url/users/${this.signedInUser.id}.json$authString');
      if(response.statusCode >= 400) {
        throw new HttpException('Failed to remove data from user.');
      }
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateUser(User user) async {
    final body = json.encode({
      'userName': user.userName,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'description': user.description,
      'locality': user.locality,
    });
    final errorMsg = 'Failed to update profile information.';
    try {
      final response =
      await http.patch('$url/users/${user.id}.json$authString', body: body);
      if (response.statusCode >= 400 || response.statusCode >= 400) {
        throw new HttpException(errorMsg);
      }
      this._users.removeWhere((u) => user.id == u.id);
      this._users.add(user);
      this.notifyListeners();
    } catch (error) {
      print(error);
      throw new HttpException(errorMsg);
    }
  }


  Future<void> updateAvatarUrl(String avatarUrl, String userId) async {
    final body = json.encode({'avatarUrl': avatarUrl});
    final errorMsg = 'Failed to update avatar url. [userId=$userId]';
    try {
      final response =
      await http.patch('$url/users/$userId.json$authString', body: body);
      if (response.statusCode >= 400 || response.statusCode >= 400) {
        throw new HttpException(errorMsg);
      }
      final user = _users.firstWhere((u) => u.id == userId);
      _users.removeWhere((u) => u.id == userId);
      _users.add(User(
        id: user.id,
        uuid: user.uuid,
        userName: user.userName,
        locality: user.locality,
        lastName: user.locality,
        follows: user.follows,
        firstName: user.firstName,
        followers: user.followers,
        age: user.age,
        description: user.description,
        avatarUrl: avatarUrl,
      ));
      this.notifyListeners();
    } catch (error) {
      print(error);
      throw new HttpException(errorMsg);
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

  Future<int> _updateFollows(String userId, List<String> follows) async {
    final body = json.encode({
      'follows': follows,
    });
    try {
      final response = await http.patch(
          '$url/users/$userId.json$authString',
          body: body);
      return response.statusCode;
    } catch (error) {
      throw error;
    }
  }
}

