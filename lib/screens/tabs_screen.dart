import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salto/components/base_app_bar.dart';
import 'package:salto/providers/users.dart';
import 'package:salto/screens/feed_screen.dart';
import 'package:salto/screens/follower_screen.dart';

import '../models/user.dart';
import 'upload_screen.dart';

class TabsScreen extends StatefulWidget {
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  List<Map<String, Object>> _pages;
  int _selectedPageIndex = 0;
  User _currentUser;

  @override
  void initState() {
    var userData = Provider.of<Users>(context, listen: false);
    userData.login('fleekboi');
    if (userData.currentUser == null) {
      /*showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: Text('Error occured.'),
              content: Text('Failed to login.'),
              actions: <Widget>[FlatButton(child: Text('Ok'))],
            );
          });*/
    } else {
      this._currentUser = userData.currentUser;
    }

      _pages = [
        {'page': FeedScreen(), 'title': 'All'},
        {'page': FollowerScreen(), 'title': 'Following'},
      ];
      super.initState();
    }

    void _selectPage(int index) {
      setState(() {
        this._selectedPageIndex = index;
      });
    }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: BaseAppBar(this._currentUser),
      body: this._pages[this._selectedPageIndex]['page'],
      bottomNavigationBar: BottomNavigationBar(
        onTap: this._selectPage,
        backgroundColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.white,
        selectedItemColor: Theme.of(context).accentColor,
        currentIndex: this._selectedPageIndex,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(Icons.home),
            title: Text('All'),
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(Icons.favorite_border),
            title: Text('Following'),
          ),
        ],
      ),
    );
  }
}
