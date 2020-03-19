import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salto/providers/content-items.dart';
import 'package:salto/providers/users.dart';
import 'package:salto/screens/feed_screen.dart';
import 'package:salto/screens/post_screen.dart';
import 'package:salto/screens/profile_screen.dart';
import 'package:salto/screens/search_screen.dart';
import 'package:salto/screens/settings_screen.dart';
import 'package:salto/screens/tabs_screen.dart';
import 'package:salto/screens/upload_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: ContentItems()),
        ChangeNotifierProvider.value(value: Users()),
      ],
      child: MaterialApp(
          title: 'Salto',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
            textTheme: TextTheme(
              title: TextStyle(color: Colors.white),
            ),
          ),
          initialRoute: '/',
          routes: {
            '/': (ctx) => TabsScreen(),
            PostScreen.route: (ctx) => PostScreen(),
            SettingsScreen.route: (ctx) => SettingsScreen(),
            UploadScreen.route: (ctx) => UploadScreen(),
            ProfileScreen.route: (ctx) => ProfileScreen(),
            SearchScreen.route: (ctx) => SearchScreen(),
          },
          onUnknownRoute: (settings) =>
              MaterialPageRoute(builder: (ctx) => FeedScreen())),
    );
  }
}
