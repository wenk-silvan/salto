import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salto/providers/content-items.dart';
import 'package:salto/providers/users.dart';

class ProfileScreen extends StatelessWidget {
  static const route = '/profile';
  static const _placeholderAvatarUrl =
      'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png';

  @override
  Widget build(BuildContext context) {
    final userId = ModalRoute.of(context).settings.arguments as String;
    final user = Provider.of<Users>(context, listen: false).findById(userId);
    return Scaffold(
      appBar: AppBar(
        title: Text(user.userName),
        actions: <Widget>[
          IconButton(
            onPressed: () => print('Let\'s follow ${user.userName}'),
            color: Colors.white,
            icon: Icon(Icons.favorite_border),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: 250,
            width: double.infinity,
            child: Image.network(
                user.avatarUrl != null && user.avatarUrl.isNotEmpty
                    ? user.avatarUrl
                    : _placeholderAvatarUrl,
                fit: BoxFit.cover),
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
            height: 60,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Chip(
                  label: Row(
                    children: <Widget>[
                      Icon(
                        Icons.favorite,
                        color: Theme.of(context).textTheme.title.color,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                          '${user.followers.length} ${user.followers.length == 1 ? 'Follower' : 'Followers'}',
                          style: TextStyle(
                              color:
                              Theme.of(context).textTheme.title.color)),
                    ],
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                Chip(
                  label: Row(
                    children: <Widget>[
                      Icon(
                        Icons.home,
                        color: Theme.of(context).textTheme.title.color,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text('${user.locality}',
                          style: TextStyle(
                              color:
                              Theme.of(context).textTheme.title.color)),
                    ],
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
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
          Consumer<ContentItems>(
              builder: (ctx, contentItemsData, _) {
                final userContentMediaUrls = contentItemsData.getMediaByUserId(userId);
                return SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(10.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                      ),
                      itemCount: 1,
                      itemBuilder: (ctx, i) => Image.network(userContentMediaUrls[i]),
                    ),
                  ),
                );
              }
          )
        ],
      ),
    );
  }
}
