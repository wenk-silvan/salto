import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salto/components/confirm_dialog.dart';
import 'package:salto/components/stylish_raised_button.dart';
import 'package:salto/providers/auth.dart';
import 'package:salto/providers/users.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  static const route = '/settings';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  SharedPreferences prefs;

  String name;
  bool autoplay = false;
  bool notifications = false;
  bool darkmode = false;

  @override
  void initState() {
    super.initState();
    readLocal();
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    autoplay = prefs.getBool('autoplay') ?? false;
    notifications = prefs.getBool('notifications') ?? false;
    darkmode = prefs.getBool('darkmode') ?? false;

    // for testing, use prefs.clear() here to clear shared_preferences
    setState(() {});
  }

  void _deleteAccount() async {
    await Provider.of<Auth>(context).deleteAccount();
    Provider.of<Users>(context).removeSignedInUser();
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  void _confirmDeleteAccount() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return ConfirmDialog(
            callback: this._deleteAccount,
            statement: 'Remove your account and all it`s data?',
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          SwitchListTile(
            title: const Text('Autoplay'),
            value: autoplay,
            onChanged: (value) {
              prefs.setBool('autoplay', value);
              // switch autoplay
              print('toggled autoplay');
            },
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: darkmode,
            onChanged: (value) {
              prefs.setBool('darkmode', value);
              // switch to dark mode
              print('toggled darkmode');
            },
          ),
          SwitchListTile(
            title: const Text('Notifications'),
            value: notifications,
            onChanged: (value) {
              prefs.setBool('notifications', value);
              // update notifications
              print('toggled notifications');
            },
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              StylishRaisedButton(
                callback: this._confirmDeleteAccount,
                child: Text('Delete Account',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.title.color)),
              ),
            ],
          )
        ],
      ),
    );
  }
}
