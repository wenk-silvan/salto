import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salto/components/base_app_bar.dart';
import 'package:salto/components/feed.dart';
import 'package:salto/models/http_exception.dart';
import 'package:salto/providers/auth.dart';
import 'package:salto/providers/content-items.dart';
import 'package:salto/providers/users.dart';

class TabsScreen extends StatefulWidget {
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  Users _userData;
  List<Map<String, Object>> _pages;
  int _selectedPageIndex = 0;
  bool _isInit;

  @override
  void initState() {
    _isInit = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInit) {
      _pages = _pagesBuilder();
      return _scaffoldBuilder();
    } else {
      return FutureBuilder(
        future: _initialize(context),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _loadingScreenBuilder();
          } else {
            if (snapshot.hasError) {
              return _errorScreenBuilder();
            } else {
              _pages = _pagesBuilder();
              return _scaffoldBuilder();
            }
          }
        },
      );
    }
  }

  BottomNavigationBar _bottomNavBar() {
    return BottomNavigationBar(
      onTap: this._selectPage,
      backgroundColor: Theme
          .of(context)
          .primaryColor,
      unselectedItemColor: Colors.white,
      selectedItemColor: Theme
          .of(context)
          .accentColor,
      currentIndex: this._selectedPageIndex,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: [
        BottomNavigationBarItem(
          backgroundColor: Theme
              .of(context)
              .primaryColor,
          icon: Icon(Icons.home),
          title: Text('All'),
        ),
        BottomNavigationBarItem(
          backgroundColor: Theme
              .of(context)
              .primaryColor,
          icon: Icon(Icons.star),
          title: Text('Following'),
        ),
      ],
    );
  }

  Widget _errorScreenBuilder() {
    return Scaffold(
      appBar: this._simpleAppBar(),
      body: Center(child: Text('An error occurred!')),
      bottomNavigationBar: this._bottomNavBar(),
    );
  }

  Future<void> _initialize(BuildContext ctx) async {
    try {
      _userData = Provider.of<Users>(ctx, listen: false);
      await _userData.getUsers();
      this._userData.login(Provider
          .of<Auth>(ctx, listen: false)
          .userId);
      await Provider.of<ContentItems>(ctx, listen: false).getContent(
          _userData.signedInUser);
      _isInit = false;
    } on HttpException catch (error) {
      print(error);
    }
  }

  Widget _loadingScreenBuilder() {
    return Scaffold(
      appBar: this._simpleAppBar(),
      body: Center(child: CircularProgressIndicator()),
      bottomNavigationBar: this._bottomNavBar(),
    );
  }

  List<Map<String, Widget>> _pagesBuilder() {
    return [
      {'page': Feed(Provider.of<ContentItems>(context, listen: false).items)},
      {'page': Feed(Provider.of<ContentItems>(context, listen: false).favItems)},
    ];
  }

  Scaffold _scaffoldBuilder() {
    return Scaffold(
      appBar: BaseAppBar(),
      body: RefreshIndicator(
        child: _pages[_selectedPageIndex]['page'],
        onRefresh: () => Provider.of<ContentItems>(context).getContent(_userData.signedInUser),
      ),
      bottomNavigationBar: _bottomNavBar(),
    );
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
}
