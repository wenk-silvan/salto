import 'package:flutter/material.dart';
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
    setState((){});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(children: <Widget>[
        SwitchListTile(
          title: Text('Autoplay'),
          value: autoplay,
          onChanged: (value) {
            prefs.setBool('autoplay', value);
            // switch autoplay
            print('toggled autoplay');
          },
        ),
        SwitchListTile(
          title: Text('Dark Mode'),
          value: darkmode,
          onChanged: (value) {
            prefs.setBool('darkmode', value);
            // switch to dark mode
            print('toggled darkmode');
          },
        ),
        SwitchListTile(
          title: Text('Notifications'),
          value: notifications,
          onChanged: (value) {
            prefs.setBool('notifications', value);
            // update notifications
            print('toggled notifications');
          },
        )
      ]),
    );
  }
}
