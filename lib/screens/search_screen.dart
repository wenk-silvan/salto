import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salto/components/search_user_result.dart';
import 'package:salto/models/user.dart';
import 'package:salto/providers/users.dart';

class SearchScreen extends StatefulWidget {
  static const route = '/search';

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _filter = new TextEditingController();
  List<User> users = new List<User>();
  Timer _timer;

  _onChangedInput() {
    if (this._timer == null) {
      this._timer = Timer(Duration(milliseconds: 500), _updateFilter);
    }
  }

  Future<void> _updateFilter() {
    if (_filter.text.isEmpty) {
      setState(() {
        this.users = [];
      });
    } else {
      setState(() {
        print("Find users: " + _filter.text);
        this.users =
            Provider.of<Users>(context, listen: false).findByName(_filter.text);
      });
    }
    this._timer = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          controller: _filter,
          onChanged: (_) => this._onChangedInput(),
          decoration: new InputDecoration(
            hintText: 'Search...',
          ),
        ),
      ),
      body: ListView.builder(
        itemBuilder: (_, i) => SearchUserResult(this.users[i]),
        itemCount: this.users.length,
      ),
    );
  }
}
