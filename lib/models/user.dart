import 'package:flutter/material.dart';

import '../dummy_data.dart';

class User {
  final String id;
  final String userName;
  final String firstName;
  final String lastName;
  final String userDescription;
  final String locality;
  final int age;
  final String avatarUrl;
  final List<String> follows;

  const User(
      {@required this.id,
      @required this.userName,
      this.firstName,
      this.lastName,
      this.userDescription,
      this.locality,
      this.age,
      this.avatarUrl,
      @required this.follows});
}
