import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/user.dart';
import 'package:http/http.dart' as http;

class Users with ChangeNotifier {
  static const url = "https://salto-7fab8.firebaseio.com/";
  List<User> _users = [];

  User signedInUser;

  List<User> get users {
    return this._users;
  }

  Future<void> addUser(User user) async {
    final body = User.toJson(user);
    this._users.add(User(
      id: user.id,
      uuid: user.uuid,
      userName: user.userName,
      locality: user.locality,
      lastName: user.lastName,
      follows: user.follows,
      firstName: user.firstName,
      followers: user.followers,
      description: user.description,
      avatarUrl: user.avatarUrl,
      age: user.age,
    ));
    final response = await http.post(url + "users.json", body: body);
    this._users.removeWhere((u) => u.uuid == user.uuid);
    this._users.add(User(
      id: json.decode(response.body)['name'],
      uuid: user.uuid,
      userName: user.userName,
      locality: user.locality,
      lastName: user.lastName,
      follows: user.follows,
      firstName: user.firstName,
      followers: user.followers,
      description: user.description,
      avatarUrl: user.avatarUrl,
      age: user.age,
    ));
    this.notifyListeners();
  }

  User findById(String userId) {
    if(this._users == null) return null;
    return this._users.firstWhere((u) => u.id == userId);
  }

  Future<void> getUsers() async {
    final response = await http.get(url + 'users.json');
    final List<User> loadedUsers = [];
    final extracted = json.decode(response.body) as Map<String, dynamic>;
    if (extracted == null) return;
    extracted.forEach(
            (id, data) => loadedUsers.add(User.fromJson(id, data)));
    this._users = loadedUsers.toList();
    print("Loaded users from database.");
    this.notifyListeners();
  }

  User login(String uuid) {
    this.signedInUser = this._users.firstWhere((u) => u.uuid == uuid,
        orElse: () => User(
              followers: [],
              id: '',
              firstName: '',
              follows: [],
              lastName: '',
              locality: '',
              userName: '',
              description: '',
              age: 0,
              avatarUrl: '',
            ));
    print('Logged in user: ${this.signedInUser.userName} - uuid: $uuid');
    return this.signedInUser;
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
    }
    else {
      //Add
      follows.add(user.id);
      followers.add(this.signedInUser.id);
    }

    try {
      final statusCodeFollowers = await this._updateFollowers(user.id, followers);
      final statusCodeFollows = await this._updateFollows(follows);
      if (statusCodeFollowers >= 400 || statusCodeFollows >= 400) {
        print("Error while changing followers.");
      }
      this.notifyListeners();
    } catch (error) {
      print(error);
      this.notifyListeners();
    }
  }

  Future<int> _updateFollowers(String userId, List<String> followers) async {
    final body = json.encode({
      'followers': followers,
    });
    try {
      final response =
      await http.patch(url + "/users/$userId.json", body: body);
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
      final response =
      await http.patch(url + "/users/${this.signedInUser.id}.json", body: body);
      return response.statusCode;
    } catch (error) {
      throw error;
    }
  }
}
