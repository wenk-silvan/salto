import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:salto/components/chip_icon.dart';
import 'package:salto/components/confirm_dialog.dart';
import 'package:salto/components/dark_dialog.dart';
import 'package:salto/components/stylish_raised_button.dart';
import 'package:salto/components/video_thumbnail.dart';
import 'package:salto/models/user.dart';
import 'package:salto/providers/auth.dart';
import 'package:salto/providers/comments.dart';
import 'package:salto/providers/content-items.dart';
import 'package:salto/providers/users.dart';
import 'package:salto/models/http_exception.dart';
import 'package:salto/screens/splash_screen.dart';

import 'camera_screen.dart';
import 'feed_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const route = '/profile';
  static const _placeholderAvatarUrl =
      'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _userNameFocusNode = FocusNode();
  final _localityFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  static const List<String> menuEntries = <String>[
    'Edit Profile',
    'Delete Profile',
    'Logout',
  ];
  Map<String, String> _updatingUserData = {
    'userName': '',
    'firstName': '',
    'lastName': '',
    'description': '',
    'locality': '',
  };
  User _user;
  Users _userData;
  bool _isMe = false;
  bool _isLoading = false;
  bool _iconVisible = false;
  String changed;

  @override
  void dispose() {
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _userNameFocusNode.dispose();
    _localityFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _userData = Provider.of<Users>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!Provider.of<Auth>(context).isAuth) {
      Navigator.of(context).pop();
      return SplashScreen();
    }
    final args = ModalRoute.of(context).settings.arguments as dynamic;
    _user = _userData.findById(args['userId']);
    _isMe = _userData.signedInUser.id == _user.id;
    return Scaffold(
      appBar: _appBarBuilder(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  _profilePictureBuilder(),
                  SizedBox(height: 10),
                  _profileNameBuilder(),
                  _profileDetailsBuilder(),
                  _profileDescriptionBuilder(),
                  SizedBox(height: 10),
                  _postPreviewBuilder(),
                ],
              ),
            ),
    );
  }

  AppBar _appBarBuilder() {
    return AppBar(
      title: Text(_user.userName),
      actions: <Widget>[
        _isMe
            ? PopupMenuButton(
                onSelected: _choiceAction,
                itemBuilder: (BuildContext ctx) {
                  return menuEntries
                      .map((entry) => PopupMenuItem<String>(
                          value: entry, child: Text(entry)))
                      .toList();
                },
              )
            : IconButton(
                onPressed: () => _userData.toggleFollowingStatus(_user),
                color: Colors.white,
                icon: Icon(_userData.follows(_user.id)
                    ? Icons.star
                    : Icons.star_border),
              )
      ],
    );
  }

  Widget _postPreviewBuilder() {
    final posts =
        Provider.of<ContentItems>(context).getContentByUserId(_user.id);
    final postUrls = posts.map((p) => p.mediaUrl).toList();
    if (postUrls.length == 0) {
      return Center(child: Text('No posts yet.'));
    }
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.36),
        child: GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 4 / 3,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
          ),
          itemCount: posts.length,
          itemBuilder: (ctx, i) => InkWell(
            onTap: () =>
                Navigator.pushNamed(context, FeedScreen.route, arguments: {
              'user': _user,
              'startIndex': i,
            }),
            child: VideoThumbnail(postUrls[i]),
          ),
        ),
      ),
    );
  }

  Widget _profileDescriptionBuilder() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      width: double.infinity,
      child: Text(
        _user.description,
        textAlign: TextAlign.center,
        softWrap: true,
      ),
    );
  }

  Widget _profileDetailsBuilder() {
    return Container(
      padding: EdgeInsets.all(10),
      height: MediaQuery.of(context).size.height * 0.08,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          ChipIcon(
              Icons.star,
              '${_user.followers.length} ${_user.followers.length == 1 ? 'Follower' : 'Followers'}',
              context),
          ChipIcon(Icons.home,
              _user.locality.isEmpty ? 'Unknown' : _user.locality, context),
        ],
      ),
    );
  }

  Widget _profileNameBuilder() {
    return Text(
      '${_user.firstName} ${_user.lastName}',
      style: TextStyle(
        color: Theme.of(context).textTheme.headline.color,
        fontSize: 20,
      ),
    );
  }

  Widget _profilePictureBuilder() {
    return GestureDetector(
      onTap: () {
        if (!_isMe) return;
        setState(() {
          _iconVisible = true;
        });
        Timer(
            Duration(seconds: 2),
            () => setState(() {
                  _iconVisible = false;
                }));
      },
      child: Stack(
        children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints(
                minWidth: double.infinity,
                maxHeight: MediaQuery.of(context).size.height * 0.35),
            child: Image.network(
              _user.avatarUrl != null && _user.avatarUrl.isNotEmpty
                  ? _user.avatarUrl
                  : ProfileScreen._placeholderAvatarUrl,
              fit: BoxFit.cover,
            ),
          ),
          AnimatedOpacity(
            opacity: _iconVisible ? 1.0 : 0.0,
            duration: Duration(milliseconds: 300),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.35,
              width: double.infinity,
              color: Colors.black45,
              child: Center(
                child: Container(
                  width: 150,
                  child: _iconVisible
                      ? StylishRaisedButton(
                          callback: () => this._choosePicture(context),
                          child: Text(
                            'New Picture',
                            style: TextStyle(
                              color: Theme.of(context).textTheme.title.color,
                            ),
                          ),
                        )
                      : SizedBox(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textFormFieldBuilder({
    BuildContext context,
    String title,
    String initialValue,
    FocusNode currentNode,
    FocusNode nextNode,
    String dataField,
    int maxLines = 1,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(labelText: title),
      textInputAction:
          nextNode != null ? TextInputAction.next : TextInputAction.done,
      focusNode: currentNode,
      onFieldSubmitted: (_) => nextNode != null
          ? FocusScope.of(context).requestFocus(nextNode)
          : _saveForm(),
      maxLines: maxLines,
      onSaved: (value) => _updatingUserData[dataField] = value,
    );
  }

  void _choiceAction(String choice) {
    if (choice == 'Edit Profile') {
      _editFormDialog();
    } else if (choice == 'Logout') {
      _logout();
    } else if (choice == 'Delete Profile') {
      _confirmDeleteAccount();
    }
  }

  void _choosePicture(BuildContext ctx) async {
    final File image = await FilePicker.getFile(type: FileType.image);
    if (image == null) return;
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return ConfirmDialog(
            callback: () {
              Navigator.of(ctx).pop();
              _uploadPicture(image);
            },
            statement: 'Set Profile Picture',
            child: Image.file(image, fit: BoxFit.contain),
          );
        });
  }

  void _confirmDeleteAccount() {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return ConfirmDialog(
            callback: () => this._deleteAccount(ctx),
            statement: 'Remove your account and all its data?',
          );
        });
  }

  void _deleteAccount(BuildContext ctx) async {
    try {
      await Provider.of<ContentItems>(ctx, listen: false)
          .deleteContentOfUser(_user.id);
      await Provider.of<Comments>(ctx, listen: false)
          .deleteCommentsOfUser(_user.id, []);
      await Provider.of<Users>(ctx, listen: false).removeSignedInUser();
      await Provider.of<Auth>(ctx, listen: false).deleteAccount();
    } on HttpException catch (error) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Error while removing profile.'),
      ));
    }
    Navigator.pop(ctx);
    _logout();
  }

  void _editFormDialog() {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          final content = Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Container(
                height: 400,
                child: Column(
                  children: <Widget>[
                    _textFormFieldBuilder(
                      context: ctx,
                      title: 'User Name',
                      currentNode: _userNameFocusNode,
                      nextNode: _firstNameFocusNode,
                      initialValue: _user.userName,
                      dataField: 'userName',
                    ),
                    _textFormFieldBuilder(
                      context: ctx,
                      title: 'First Name',
                      currentNode: _firstNameFocusNode,
                      nextNode: _lastNameFocusNode,
                      initialValue: _user.firstName,
                      dataField: 'firstName',
                    ),
                    _textFormFieldBuilder(
                      context: ctx,
                      title: 'Last Name',
                      currentNode: _lastNameFocusNode,
                      nextNode: _localityFocusNode,
                      initialValue: _user.lastName,
                      dataField: 'lastName',
                    ),
                    _textFormFieldBuilder(
                      context: ctx,
                      title: 'Locality',
                      currentNode: _localityFocusNode,
                      nextNode: _descriptionFocusNode,
                      initialValue: _user.locality,
                      dataField: 'locality',
                    ),
                    _textFormFieldBuilder(
                      context: ctx,
                      title: 'Description',
                      currentNode: _descriptionFocusNode,
                      nextNode: null,
                      initialValue: _user.description,
                      dataField: 'description',
                      maxLines: 3,
                    ),
                    Spacer(),
                    Row(
                      children: <Widget>[
                        FlatButton(
                          child: Text('Cancel'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Spacer(),
                        FlatButton(
                          child: Text('Update'),
                          onPressed: _saveForm,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
          return DarkDialog(
            content: content,
            statement: 'Update Profile',
            brightMode: true,
          );
        });
  }

  void _logout() {
    Provider.of<Auth>(context, listen: false).logout();
  }

  void _saveForm() async {
    Navigator.of(context).pop();
    try {
      _formKey.currentState.save();
      setState(() {
        _isLoading = true;
      });
      final modifiedUser = User(
        id: _user.id,
        uuid: _user.uuid,
        userName: _updatingUserData['userName'],
        locality: _updatingUserData['locality'],
        lastName: _updatingUserData['lastName'],
        follows: _user.follows,
        firstName: _updatingUserData['firstName'],
        followers: _user.followers,
        description: _updatingUserData['description'],
        avatarUrl: _user.avatarUrl,
        age: _user.age,
      );
      await Provider.of<Users>(context).updateUser(modifiedUser);
    } on HttpException catch (_) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to update profile.')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _uploadPicture(File file) async {
    setState(() {
      _isLoading = true;
    });
    final oldUser = _user;
    try {
      final downloadUrl =
          await Provider.of<ContentItems>(context, listen: false)
              .uploadToStorage(file, 'images', '${_user.id}.jpg');
      await Provider.of<Users>(context).updateAvatarUrl(downloadUrl, _user.id);
    } on HttpException catch (error) {
      setState(() {
        _user = oldUser;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
