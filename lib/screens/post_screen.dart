import 'package:flutter/material.dart';

class PostScreen extends StatelessWidget {
  static const route = '/post';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('The Post'),
      ),
      body: Text('Content'),
    );
  }
}
