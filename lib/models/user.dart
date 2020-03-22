import 'dart:convert';

import 'package:flutter/material.dart';

class User {
  final String id;
  final String uuid;
  final String userName;
  final String firstName;
  final String lastName;
  final String description;
  final String locality;
  final int age;
  final String avatarUrl;
  final List<String> follows;
  final List<String> followers;

  const User(
      {@required this.id,
      @required this.uuid,
      @required this.userName,
      @required this.firstName,
      @required this.lastName,
      @required this.locality,
      this.avatarUrl,
      this.age,
      this.description,
      @required this.follows,
      @required this.followers});

  static User fromJson(userId, userData) {
    return User(
      id: userId,
      uuid: userData['uuid'],
      firstName: userData['firstName'],
      followers: userData['followers'] == null
          ? []
          : (userData['followers'] as List<dynamic>)
          .map((userId) => userId.toString())
          .toList(),
      follows: userData['follows'] == null
          ? []
          : (userData['follows'] as List<dynamic>)
          .map((userId) => userId.toString())
          .toList(),
      lastName: userData['lastName'],
      locality: userData['locality'],
      userName: userData['userName'],
      age: userData['age'],
      avatarUrl: userData['avatarUrl'],
      description: userData['description'],
    );
  }

  static String toJson(User user) {
    return json.encode({
      'uuid': user.uuid,
      'userName': user.userName,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'locality': user.locality,
      'avatarUrl': user.avatarUrl,
      'age': user.age,
      'description': user.description,
      'follows': user.follows,
      'followers': user.followers,
    });
  }
}
