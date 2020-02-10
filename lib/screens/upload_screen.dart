import 'package:flutter/material.dart';

import '../models/content-item.dart';
import '../models/content-item.dart';

class UploadScreen extends StatefulWidget {
  static const route = '/upload';

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final String _imageUrl =
      'https://images.unsplash.com/photo-1573766917336-4ce32afd1907?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=750&q=80';
  final _form = GlobalKey<FormState>();
  var _newContentItem = ContentItem(
    title: '',
    timestamp: DateTime.now(),
    comments: [],
    id: '',
    likeCount: 0,
    likes: [],
    mediaUrl: '',
    userId: 'ed4f546q',
    description: ''
  );

  void _addPost() {
    //TODO: Add to data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add new Post'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              this._addPost();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                textInputAction: TextInputAction.next,
                onSaved: (value) => this._newContentItem = ContentItem(

                ),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                textInputAction: TextInputAction.done,
              ),
              SizedBox(
                height: 30,
              ),
              Image.network(
                this._imageUrl,
                fit: BoxFit.cover,
              )
            ],
          ),
        ),
      ),
    );
  }
}
