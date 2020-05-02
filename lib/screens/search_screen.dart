import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salto/components/search_post_result.dart';
import 'package:salto/components/search_user_result.dart';
import 'package:salto/models/content-item.dart';
import 'package:salto/models/user.dart';
import 'package:salto/providers/auth.dart';
import 'package:salto/providers/content-items.dart';
import 'package:salto/providers/users.dart';
import 'package:salto/screens/splash_screen.dart';

class SearchScreen extends StatefulWidget {
  static const route = '/search';

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<User> users = new List<User>();
  List<ContentItem> content = [];
  Timer _timer;
  bool _userTabActivated = true;
  bool _isLoading = false;
  final TextEditingController _filter = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (!Provider.of<Auth>(context).isAuth) {
      Navigator.of(context).pop();
      return SplashScreen();
    }
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            autofocus: true,
            controller: _filter,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white),
            onChanged: (_) => this._onChangedInput(),
            decoration: new InputDecoration(
              hintText: 'Search...',
              hintStyle: TextStyle(color: Colors.white54),
              suffixIcon: this._filter.text.isEmpty ? null : IconButton(
                icon: Icon(Icons.clear),
                color: Colors.white,
                onPressed: () {
                  setState(() {
                    this._filter.clear();
                    this._updateFilter();
                  });
                },
              )
            ),
          ),
          bottom: TabBar(
            onTap: (index) {
              index == 0 ? _userTabActivated = true : _userTabActivated = false;
              this._updateFilter();
            },
            tabs: <Widget>[
              Tab(icon: Icon(Icons.person)),
              Tab(icon: Icon(Icons.movie)),
            ],
          ),
        ),
        body: this._isLoading
            ? Center(child: CircularProgressIndicator())
            : TabBarView(
                children: <Widget>[
                  this.users.length < 1
                      ? Center(
                          child: Text(
                              '${_filter.text.isEmpty ? 'Type to search users.' : 'No users where found.'}'))
                      : ListView.builder(
                          itemBuilder: (_, i) =>
                              SearchUserResult(this.users[i]),
                          itemCount: this.users.length,
                        ),
                  this.content.length < 1
                      ? Center(
                          child: Text(
                              '${_filter.text.isEmpty ? 'Type to search posts.' : 'No posts where found.'}'))
                      : ListView.builder(
                          itemBuilder: (_, i) =>
                              SearchPostResult(this.content[i]),
                          itemCount: this.content.length,
                        ),
                ],
              ),
      ),
    );
  }

  void _onChangedInput() {
    if (this._timer == null) {
      setState(() {
        this._isLoading = true;
      });
      this._timer = Timer(Duration(milliseconds: 500), _updateFilter);
    }
  }

  Future<void> _updateFilter() {
    setState(() {
      if (this._userTabActivated) {
        if (_filter.text.isEmpty) {
          this.users = [];
        } else {
          this.users = Provider.of<Users>(context, listen: false)
              .findByName(_filter.text);
        }
      } else {
        if (_filter.text.isEmpty) {
          this.content = [];
        } else {
          this.content = Provider.of<ContentItems>(context, listen: false)
              .findByTitle(_filter.text);
        }
      }
      this._isLoading = false;
    });
    this._timer = null;
  }
}
