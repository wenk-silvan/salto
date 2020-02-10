import 'package:flutter/material.dart';

class User {
  final String userName;
  final String firstName;
  final String lastName;
  final String userDescription;
  final String locality;
  final int age;
  final String avatarUrl;
  final List<String> follows;

  User(
      {@required this.userName,
      this.firstName,
      this.lastName,
      this.userDescription,
      this.locality,
      this.age,
      this.avatarUrl,
      @required this.follows});
}
