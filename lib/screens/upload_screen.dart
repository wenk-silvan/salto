import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salto/components/add_post_dialog.dart';
import 'package:salto/components/file_video_player.dart';
import 'package:salto/components/stylish_raised_button.dart';
import 'package:salto/models/user.dart';
import 'package:salto/providers/content-items.dart';
import 'package:salto/providers/users.dart';
import 'package:salto/screens/camera_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

import '../models/content-item.dart';

class UploadScreen extends StatefulWidget {
  static const route = '/upload';
  final FirebaseStorage storage;

  UploadScreen(this.storage);

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _form = GlobalKey<FormState>();
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  String _downloadUrl;
  User _signedInUser;
  File _file;
  bool _isLoading = false;
  var _newContentItem = ContentItem(
    title: '',
    timestamp: DateTime.now(),
    id: '',
    likes: [],
    mediaUrl: '',
    userId: '',
    description: '',
  );
  List<StorageUploadTask> _tasks = <StorageUploadTask>[];

  Future<void> _uploadFile(File file, String fileName) async {
    final StorageReference ref =
        widget.storage.ref().child('videos').child('$fileName.mp4');

    final StorageUploadTask uploadTask = ref.putFile(
      file,
      StorageMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'activity': 'test'},
      ),
    );
    this._downloadUrl =
        await (await uploadTask.onComplete).ref.getDownloadURL();
    setState(() {
      _tasks.add(uploadTask);
    });
  }

  void _saveForm() async {
    if (!this._form.currentState.validate()) return;
    this._form.currentState.save();
    setState(() {
      this._isLoading = true;
    });
    try {
      if (_file == null) return;
      final contentItemId =
          await Provider.of<ContentItems>(context, listen: false)
              .addContent(this._newContentItem);
      await this._uploadFile(_file, contentItemId);
      await Provider.of<ContentItems>(context, listen: false)
          .updatePost('mediaUrl', this._downloadUrl, contentItemId);
    } catch (error) {
      print(error);
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Something went wrong.')
      ));
    }
    setState(() {
      this._isLoading = false;
    });
    Navigator.of(context).pop();
    //Navigator.of(context).pop();
  }

  @override
  void dispose() {
    this._titleFocusNode.dispose();
    this._descriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _signedInUser = Provider.of<Users>(context, listen: false).signedInUser;
    _file = ModalRoute.of(context).settings.arguments as dynamic;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create new post'),
      ),
      body: this._isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Form(
                key: this._form,
                child: Column(
                  children: <Widget>[
                    FileVideoPlayer(true, _file),
                    _titleTextFieldBuilder(),
                    _descriptionTextFieldBuilder(),
                    SizedBox(height: 20),
                    _actionRowBuilder(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _actionRowBuilder() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        StylishRaisedButton(
          callback: () => showDialog(
            context: context,
            builder: (BuildContext ctx) => AddPostDialog(statement: 'Select another video.'),
          ),
          child: Icon(Icons.add_a_photo, color: Colors.white),
        ),
        StylishRaisedButton(
          callback: _saveForm,
          child: Icon(Icons.file_upload, color: Colors.white),
        ),
      ],
    );
  }

  Widget _descriptionTextFieldBuilder() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextFormField(
        decoration: InputDecoration(labelText: 'Description'),
        textInputAction: TextInputAction.done,
        focusNode: this._descriptionFocusNode,
        onFieldSubmitted: (_) => this._saveForm(),
        onSaved: (value) => this._newContentItem = ContentItem(
          title: this._newContentItem.title,
          timestamp: this._newContentItem.timestamp,
          id: this._newContentItem.id,
          likes: this._newContentItem.likes,
          mediaUrl: this._newContentItem.mediaUrl,
          userId: _signedInUser.id,
          description: value,
        ),
      ),
    );
  }

  Widget _titleTextFieldBuilder() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextFormField(
        decoration: InputDecoration(labelText: 'Title'),
        textInputAction: TextInputAction.next,
        focusNode: this._titleFocusNode,
        onFieldSubmitted: (_) =>
            FocusScope.of(context).requestFocus(this._descriptionFocusNode),
        onSaved: (value) => this._newContentItem = ContentItem(
          title: value,
          timestamp: this._newContentItem.timestamp,
          id: this._newContentItem.id,
          likes: this._newContentItem.likes,
          mediaUrl: this._newContentItem.mediaUrl,
          userId: _signedInUser.id,
          description: this._newContentItem.description,
        ),
        validator: (value) {
          if (value.isEmpty) return 'Please enter a title.';
          return null;
        },
      ),
    );
  }
}
