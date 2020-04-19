import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salto/components/chip_icon.dart';
import 'package:salto/providers/auth.dart';
import 'package:salto/providers/content-items.dart';
import 'package:salto/providers/users.dart';

class ProfileScreen extends StatelessWidget {
  static const route = '/profile';
  static const _placeholderAvatarUrl =
      'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png';

  void _logout(BuildContext ctx) {
    Provider.of<Auth>(ctx).logout();
    Navigator.pop(ctx);
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context).settings.arguments as dynamic;
    final userId = args['userId'];
    final userData = Provider.of<Users>(context);
    final user = userData.findById(userId);
    final isMe = userData.signedInUser.id == userId;
    return Scaffold(
      appBar: AppBar(
        title: Text(user.userName),
        actions: <Widget>[
          if (isMe)
            FlatButton(
              onPressed: () => this._logout(context),
              child: Text(
                'LOGOUT',
                style: TextStyle(color: Colors.white),
              ),
            )
          else
            IconButton(
              onPressed: () => userData.toggleFollowingStatus(user),
              color: Colors.white,
              icon: Icon(
                  userData.follows(userId) ? Icons.star : Icons.star_border),
            )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              width: double.infinity,
              child: Image.network(
                  user.avatarUrl != null && user.avatarUrl.isNotEmpty
                      ? user.avatarUrl
                      : _placeholderAvatarUrl,
                  fit: BoxFit.cover),
            ),
          ),
          SizedBox(height: 10),
          Text(
            '${user.firstName} ${user.lastName}',
            style: TextStyle(
              color: Theme.of(context).textTheme.headline.color,
              fontSize: 20,
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            height: MediaQuery.of(context).size.height * 0.08,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                ChipIcon(
                    Icons.star,
                    '${user.followers.length} ${user.followers.length == 1 ? 'Follower' : 'Followers'}',
                    context),
                ChipIcon(Icons.home,
                    user.locality.isEmpty ? 'Unknown' : user.locality, context),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            width: double.infinity,
            child: Text(
              user.description,
              textAlign: TextAlign.center,
              softWrap: true,
            ),
          ),
          SizedBox(height: 10),
          /*Consumer<ContentItems>(builder: (ctx, content, _) {
            final contentUrls = content.getContentByUserId(userId);
            return SingleChildScrollView(
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.36,
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1 / 1,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  itemCount: contentUrls.length,
                  itemBuilder: (ctx, i) => Image.network(
                    contentUrls[i],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          })*/
        ],
      ),
    );
  }
}
