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
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  var _newContentItem = ContentItem(
    title: '',
    timestamp: DateTime.now(),
    comments: [],
    id: '',
    likes: [],
    mediaUrl: '',
    userId: 'ed4f546q',
    description: ''
  );

  void _saveForm() {
    if (!this._form.currentState.validate()) return;
    //TODO: Add to data
    this._form.currentState.save();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    this._titleFocusNode.dispose();
    this._descriptionFocusNode.dispose();
    super.dispose();
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
              this._saveForm();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: this._form,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                textInputAction: TextInputAction.next,
                focusNode: this._titleFocusNode,
                onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(this._descriptionFocusNode),
                onSaved: (value) => this._newContentItem = ContentItem(
                    title: value,
                    timestamp: this._newContentItem.timestamp,
                    id: this._newContentItem.id,
                    comments: this._newContentItem.comments,
                    likes: this._newContentItem.likes,
                    mediaUrl: this._newContentItem.mediaUrl,
                    userId: this._newContentItem.userId,
                    description: this._newContentItem.description,
                ),
                validator: (value) {
                  if (value.isEmpty) return 'Please enter a title.';
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                textInputAction: TextInputAction.done,
                focusNode: this._descriptionFocusNode,
                onFieldSubmitted: (_) => this._saveForm(),
                onSaved: (value) => this._newContentItem = ContentItem(
                  title: this._newContentItem.title,
                  timestamp: this._newContentItem.timestamp,
                  id: this._newContentItem.id,
                  comments: this._newContentItem.comments,
                  likes: this._newContentItem.likes,
                  mediaUrl: this._newContentItem.mediaUrl,
                  userId: this._newContentItem.userId,
                  description: value,
                ),
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
