import 'package:flutter/material.dart';

class UploadScreen extends StatelessWidget {
  static const route = '/upload';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload'),
      ),
      body: Text('Upload Screen Content'),
    );
  }
}
