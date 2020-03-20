import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salto/components/search_post_result.dart';
import 'package:salto/components/search_user_result.dart';
import 'package:salto/models/content-item.dart';
import 'package:salto/models/user.dart';
import 'package:salto/providers/content-items.dart';
import 'package:salto/providers/users.dart';

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
  final TextEditingController _filter = new TextEditingController();

  _onChangedInput() {
    if (this._timer == null) {
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
    });
    this._timer = null;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            autofocus: true,
            controller: _filter,
            onChanged: (_) => this._onChangedInput(),
            decoration: new InputDecoration(
              hintText: 'Search...',
            ),
          ),
          bottom: TabBar(
            onTap: (index) {
              index == 0 ? _userTabActivated = true : _userTabActivated = false;
              this._updateFilter();
            },
            tabs: <Widget>[
              Tab(icon: Icon(Icons.person)),
              Tab(icon: Icon(Icons.photo)),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            ListView.builder(
              itemBuilder: (_, i) => SearchUserResult(this.users[i]),
              itemCount: this.users.length,
            ),
            ListView.builder(
              itemBuilder: (_, i) => SearchPostResult(this.content[i]),
              itemCount: this.content.length,
            ),
          ],
        ),
      ),
    );
  }
}
