import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:salto/models/http_exception.dart';

import 'dart:io';
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
    this.getUsers();
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
    try {
      final response = await http.get('$url/users.json$authString');
      if(response.statusCode >= 400) {
        print(json.decode(response.body)['error']['message']);
        throw new HttpException('Could not fetch users.');
      }
      final List<User> loadedUsers = [];
      final responseBody = json.decode(response.body) as Map<String, dynamic>;
      if (responseBody == null) return;
      responseBody.forEach((id, data) => loadedUsers.add(User.fromJson(id, data)));
      this._users = loadedUsers.toList();
      this.notifyListeners();
    } on SocketException catch (_) {
      throw HttpException('No network connection.');
    } catch (error) {
      print(error);
      throw error;
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
    try {
      await this._updateFollowers(user.id, followers);
      await this._updateFollows(this.signedInUser.id, follows);
    } catch (error) {
      print(error);
      throw error;
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
        print(json.decode(response.body)['error']['message']);
        throw new HttpException('Could not remove user data.');
      }
      notifyListeners();
    } on SocketException catch (_) {
      throw HttpException('No network connection.');
    } catch (error) {
      print(error);
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
    try {
      final response =
      await http.patch('$url/users/${user.id}.json$authString', body: body);
      if (response.statusCode >= 400) {
        print(json.decode(response.body)['error']['message']);
        throw new HttpException('Could not update user data.');
      }
      this._users.removeWhere((u) => user.id == u.id);
      this._users.add(user);
      this.notifyListeners();
    } on SocketException catch (_) {
      throw HttpException('No network connection.');
    } catch (error) {
      print(error);
      throw error;
    }
  }


  Future<void> updateAvatarUrl(String avatarUrl, String userId) async {
    final body = json.encode({'avatarUrl': avatarUrl});
    try {
      final response =
      await http.patch('$url/users/$userId.json$authString', body: body);
      if (response.statusCode >= 400) {
        print(json.decode(response.body)['error']['message']);
        throw new HttpException('Failed to update avatar url.');
      }
      final user = _users.firstWhere((u) => u.id == userId);
      final clone = User(
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
      );
      _users.removeWhere((u) => u.id == userId);
      _users.add(clone);
      signedInUser = clone;
      this.notifyListeners();
    } on SocketException catch (_) {
      throw HttpException('No network connection.');
    } catch (error) {
      print(error + ' [userId=$userId]');
      throw error;
    }
  }

  Future<void> _updateFollowers(String userId, List<String> followers) async {
    final body = json.encode({
      'followers': followers,
    });
    try {
      final response =
          await http.patch('$url/users/$userId.json$authString', body: body);
      if (response.statusCode >= 400) {
        print(json.decode(response.body)['error']['message']);
        throw new HttpException('Could not toggle following status.');
      }
    } on SocketException catch (_) {
      throw HttpException('No network connection.');
    } catch (error) {
      throw error;
    }
  }

  Future<void> _updateFollows(String userId, List<String> follows) async {
    final body = json.encode({
      'follows': follows,
    });
    try {
      final response = await http.patch(
          '$url/users/$userId.json$authString',
          body: body);
      if(response.statusCode >= 400) {
        print(json.decode(response.body)['error']['message']);
        throw HttpException('Could not update follows status.');
      }
    } on SocketException catch (_) {
      throw HttpException('No network connection.');
    } catch (error) {
      throw error;
    }
  }
}

