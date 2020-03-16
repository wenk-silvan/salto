import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salto/providers/content-items.dart';

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
  var _isLoading = false;
  var _newContentItem = ContentItem(
    title: '',
    timestamp: DateTime.now(),
    comments: [],
    id: '',
    likes: [],
    mediaUrl: '',
    userId: '',
    description: '',
  );

  void _saveForm() async {
    if (!this._form.currentState.validate()) return;
    this._form.currentState.save();
    setState(() {
      this._isLoading = true;
    });
    try {
      await Provider.of<ContentItems>(context, listen: false)
          .addContent(this._newContentItem);
    } catch (error) {
      await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: Text('An error occured!'),
                content: Text('Something went wrong.'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Okay'),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                  )
                ],
              ));
    }
    setState(() {
      this._isLoading = false;
    });
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
    final userId = ModalRoute.of(context).settings.arguments as String;
    print(userId);
    return Scaffold(
      appBar: AppBar(
        title: Text('Add new Post'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: this._saveForm,
          ),
        ],
      ),
      body: this._isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: this._form,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      focusNode: this._titleFocusNode,
                      onFieldSubmitted: (_) => FocusScope.of(context)
                          .requestFocus(this._descriptionFocusNode),
                      onSaved: (value) => this._newContentItem = ContentItem(
                        title: value,
                        timestamp: this._newContentItem.timestamp,
                        id: this._newContentItem.id,
                        comments: this._newContentItem.comments,
                        likes: this._newContentItem.likes,
                        mediaUrl: this._imageUrl,
                        userId: userId,
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
                        mediaUrl: this._imageUrl,
                        userId: userId,
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
