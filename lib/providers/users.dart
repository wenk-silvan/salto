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
    final response = await http.post(url + "users.json", body: body);
    this._users.add(User(
          id: json.decode(response.body)['name'],
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

  User login(String userName) {
    this.signedInUser = this._users.firstWhere((u) => u.userName == userName,
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
    print('Logged in user: ${this.signedInUser.userName}');
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
}
