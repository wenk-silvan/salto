import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salto/components/add_post_dialog.dart';
import 'package:salto/components/file_video_player.dart';
import 'package:salto/components/stylish_raised_button.dart';
import 'package:salto/models/http_exception.dart';
import 'package:salto/models/user.dart';
import 'package:salto/providers/auth.dart';
import 'package:salto/providers/content-items.dart';
import 'package:salto/providers/storage.dart';
import 'package:salto/providers/users.dart';
import 'package:salto/screens/camera_screen.dart';
import 'package:salto/screens/splash_screen.dart';
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

  @override
  void dispose() {
    this._titleFocusNode.dispose();
    this._descriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!Provider.of<Auth>(context).isAuth) {
      Navigator.of(context).pop();
      return SplashScreen();
    }
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
                    FileVideoPlayer(key: UniqueKey(), file: _file, loop: true),
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
            builder: (BuildContext ctx) =>
                AddPostDialog(statement: 'Select another video.'),
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

  void _saveForm() async {
    if (!this._form.currentState.validate()) return;
    this._form.currentState.save();
    setState(() {
      this._isLoading = true;
    });
    final contentData = Provider.of<ContentItems>(context, listen: false);
    try {
      if (_file == null) return;
      final contentItemId = await contentData.addContent(_newContentItem);
      final fileName = '$contentItemId.mp4';
      _file.copy(
          '${Directory.systemTemp.path}/$fileName'); // Keep video in cache
      final downloadUrl = await Provider.of<Storage>(context, listen: false)
          .uploadToStorage(_file, 'videos', fileName);
      contentData.addFirst(ContentItem(
        title: _newContentItem.title,
        timestamp: _newContentItem.timestamp,
        id: contentItemId,
        likes: _newContentItem.likes,
        mediaUrl: downloadUrl,
        userId: _newContentItem.userId,
        description: _newContentItem.description,
      ));
      contentData.updatePost({'mediaUrl': downloadUrl}, contentItemId);
      Navigator.of(context).pop();
    } on HttpException catch (error) {
      HttpException.showErrorDialog(error.message, context);
    } finally {
      setState(() {
        this._isLoading = false;
      });
    }
  }
}
