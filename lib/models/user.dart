import 'package:flutter/material.dart';

import '../dummy_data.dart';

class User {
  final String id;
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
      @required this.userName,
      @required this.firstName,
      @required this.lastName,
      @required this.locality,
      this.avatarUrl,
      this.age,
      this.description,
      @required this.follows,
      @required this.followers});
}
