import 'package:flutter/foundation.dart';

import '../models/user.dart';

class Users with ChangeNotifier {
  List<User> _users = [
    User(
      id: 'ed4f546q',
      firstName: 'Fleek',
      lastName: 'Boi',
      userName: 'fleekboi',
      description:
          'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.',
      locality: 'Brussels',
      age: 21,
      avatarUrl:
          'https://upload.wikimedia.org/wikipedia/commons/c/c5/A.J.M._Arkor.jpg',
      follows: ['5a4f546e', 'hk29fjwk', '14k3l67i'],
      followers: ['5a4f546e'],
    ),
    User(
      id: '5a4f546e',
      firstName: 'Jos',
      lastName: 'Dinky',
      userName: 'dinky',
      description: 'Hey there, my name is Jos',
      locality: 'Berlin',
      age: 22,
      avatarUrl: 'https://i.pravatar.cc/150?img=57',
      follows: ['ed4f546q'],
      followers: ['ed4f546q'],
    ),
    User(
      id: 'as8f7gjk',
      firstName: 'Meg',
      lastName: 'Hardy',
      userName: 'hard_mi',
      description: 'Lorem ipsum dolor sit amet, consetetur sadipscing elitr',
      locality: 'Stockholm',
      age: 62,
      avatarUrl:
          'https://images.unsplash.com/photo-1527025047-354c31c26312?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1950&q=80',
      follows: ['ed4f546q'],
      followers: ['ed4f546q'],
    ),
    User(
      id: 'hk29fjwk',
      firstName: 'Frank',
      lastName: 'Jordan',
      userName: 'if-Jay',
      description: 'Lorem ipsum dolor sit amet, consetetur sadipscing elitr',
      locality: 'Zurich',
      age: 18,
      avatarUrl:
          'https://images.unsplash.com/photo-1503249023995-51b0f3778ccf?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1822&q=80',
      follows: ['ed4f546q', 'as8f7gjk'],
      followers: ['ed4f546q', 'as8f7gjk'],
    ),
    User(
      id: '14k3l67i',
      firstName: 'Anony',
      lastName: 'Mouse',
      userName: 'anoni',
      description: 'Lorem ipsum dolor sit amet, consetetur sadipscing elitr',
      locality: 'Hollywood',
      age: 22,
      avatarUrl:
          'https://images.unsplash.com/photo-1549998724-03a9e93f22f6?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1180&q=80',
      follows: ['ed4f546q'],
      followers: ['ed4f546q'],
    ),
    User(
      id: 'h059fj4k',
      firstName: 'Sponge',
      lastName: 'Bob',
      userName: 'bikini_guy',
      description: 'Lorem ipsum dolor sit amet, consetetur sadipscing elitr',
      locality: 'Bikini Bottom',
      age: 22,
      avatarUrl:
          'https://images.unsplash.com/photo-1565799284935-da1e43e7944e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1050&q=80',
      follows: ['ed4f546q'],
      followers: ['ed4f546q'],
    ),
  ];

  User currentUser;

  List<User> get users {
    return this._users;
  }

  User findById(String userId) {
    return this._users.firstWhere((u) => u.id == userId);
  }

  void login(String userName) {
    this.currentUser = this._users.firstWhere((u) => u.userName == userName,
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
    print('Logged in user: ${this.currentUser.userName}');
  }

  List<User> findByName(String text) {
    return this._users.where((u) {
      var lowerCaseText = text.toLowerCase();
      return u.firstName.toLowerCase().contains(lowerCaseText) ||
          u.lastName.toLowerCase().contains(lowerCaseText) ||
          u.userName.toLowerCase().contains(lowerCaseText);
    }).toList();
  }
}
