import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salto/components/base_app_bar.dart';
import 'package:salto/components/feed.dart';
import 'package:salto/models/http_exception.dart';
import 'package:salto/providers/auth.dart';
import 'package:salto/providers/content-items.dart';
import 'package:salto/providers/users.dart';
import 'package:salto/screens/auth_screen.dart';
import 'package:salto/screens/feed_screen.dart';

import '../models/user.dart';

class TabsScreen extends StatefulWidget {
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  ContentItems _contentData;
  Users _userData;
  List<Map<String, Object>> _pages;
  int _selectedPageIndex = 0;
  bool isInit = true;

  BottomNavigationBar _bottomNavBar() {
    return BottomNavigationBar(
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
          icon: Icon(Icons.star),
          title: Text('Following'),
        ),
      ],
    );
  }

  Future<void> _initialize(BuildContext ctx) async {
    this.isInit = false;
    this._userData = Provider.of<Users>(ctx, listen: false);
    this._contentData = Provider.of<ContentItems>(context);
    final authData = Provider.of<Auth>(ctx, listen: false);
    try {
      await this._userData.getUsers();
      var didLogIn = this._userData.login(authData.userId);
      if (!didLogIn) authData.logout();
      await _contentData.getContent(_userData.signedInUser);
    } on HttpException catch (error) {
      throw error;
    }
  }

  void _selectPage(int index) {
    setState(() {
      this._selectedPageIndex = index;
    });
  }

  AppBar _simpleAppBar() {
    return AppBar(
      title: Text('Salto'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: this._initialize(context),
      builder: (ctx, snapshot) {
        this._pages = [
          {'page': Feed(_contentData.items)},
          {'page': Feed(_contentData.favItems)},
        ];
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: this._simpleAppBar(),
            body: Center(child: CircularProgressIndicator()),
            bottomNavigationBar: this._bottomNavBar(),
          );
        } else {
          if (snapshot.hasError) {
            print(snapshot.error);
            return Scaffold(
              appBar: this._simpleAppBar(),
              body: Center(child: Text('An error occurred!')),
              bottomNavigationBar: this._bottomNavBar(),
            );
          } else {
            return Scaffold(
              appBar: BaseAppBar(),
              body: this._pages[this._selectedPageIndex]['page'],
              bottomNavigationBar: this._bottomNavBar(),
            );
          }
        }
      },
    );
  }
}
