import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salto/components/chip_icon.dart';
import 'package:salto/components/video_thumbnail.dart';
import 'package:salto/models/user.dart';
import 'package:salto/providers/auth.dart';
import 'package:salto/providers/content-items.dart';
import 'package:salto/providers/users.dart';

import 'feed_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const route = '/profile';
  static const _placeholderAvatarUrl =
      'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User _user;
  Users _userData;
  bool _isMe;

  void _logout(BuildContext ctx) {
    Provider.of<Auth>(ctx).logout();
    Navigator.pop(ctx);
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context).settings.arguments as dynamic;
    _userData = Provider.of<Users>(context, listen: false);
    _user = _userData.findById(args['userId']);
    _isMe = _userData.signedInUser.id == _user.id;
    return Scaffold(
      appBar: _appBarBuilder(),
      body: Column(
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
    );
  }

  AppBar _appBarBuilder() {
    return AppBar(
      title: Text(_user.userName),
      actions: <Widget>[
        if (_isMe)
          FlatButton(
            onPressed: () => this._logout(context),
            child: Text(
              'LOGOUT',
              style: TextStyle(color: Colors.white),
            ),
          )
        else
          IconButton(
            onPressed: () => _userData.toggleFollowingStatus(_user),
            color: Colors.white,
            icon: Icon(
                _userData.follows(_user.id) ? Icons.star : Icons.star_border),
          )
      ],
    );
  }

  Widget _postPreviewBuilder() {
    final posts = Provider.of<ContentItems>(context)
        .getContentByUserId(_user.id);
    final postUrls = posts.map((p) => p.mediaUrl).toList();
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.36,
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
    return Expanded(
      child: Container(
        width: double.infinity,
        child: Image.network(
            _user.avatarUrl != null && _user.avatarUrl.isNotEmpty
                ? _user.avatarUrl
                : ProfileScreen._placeholderAvatarUrl,
            fit: BoxFit.cover),
      ),
    );
  }
}
