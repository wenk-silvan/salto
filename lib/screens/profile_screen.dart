import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  static const route = '/profile';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Profile'),
      ),
      body: Text('Content'),
    );
  }
}
