import 'package:flutter/foundation.dart';

import '../models/user.dart';

class Users with ChangeNotifier {
  List<User> _users = [
    User(
      id: 'ed4f546q',
      firstName: 'Fleek',
      lastName: 'Boi',
      userName: 'fleekboi',
      description: 'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.',
      locality: 'Brussels',
      age: 21,
      avatarUrl:
      'https://upload.wikimedia.org/wikipedia/commons/c/c5/A.J.M._Arkor.jpg',
      follows: ['5a4f546e'],
      followers: ['5a4f546e']
    ),
    User(
      id: '5a4f546e',
      firstName: 'Jos',
      lastName: 'Dinky',
      userName: 'dinkyj',
      description: 'Hey there, my name is Jos',
      locality: 'Berlin',
      age: 22,
      avatarUrl: 'https://i.pravatar.cc/150?img=57',
      follows: ['ed4f546q'],
      followers: ['ed4f546q']
    )
  ];

  User currentUser;

  List<User> get users {
    return this._users;
  }

  User findById(String userId) {
    return this._users.firstWhere((u) => u.id == userId);
  }

  void login(String userName) {
    this.currentUser = this._users.firstWhere((u) => u.userName == userName, orElse: () => null);
  }
}