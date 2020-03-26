import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salto/providers/auth.dart';
import 'package:salto/providers/content-items.dart';
import 'package:salto/providers/users.dart';
import 'package:salto/screens/auth_screen.dart';
import 'package:salto/screens/post_screen.dart';
import 'package:salto/screens/profile_screen.dart';
import 'package:salto/screens/search_screen.dart';
import 'package:salto/screens/settings_screen.dart';
import 'package:salto/screens/splash_screen.dart';
import 'package:salto/screens/tabs_screen.dart';
import 'package:salto/screens/upload_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Auth()),
        ChangeNotifierProxyProvider<Auth, ContentItems>(
          builder: (ctx, auth, previousItems) => ContentItems(
              auth.token,
            previousItems == null ? [] : previousItems.items,
          ),
        ),
        ChangeNotifierProxyProvider<Auth, Users>(
          builder: (ctx, auth, previousUsers) => Users(
            auth.token,
            previousUsers == null ? [] : previousUsers.users,
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Salto',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
            textTheme: TextTheme(
              title: TextStyle(color: Colors.white),
            ),
          ),
          home: auth.isAuth
              ? TabsScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            PostScreen.route: (ctx) => PostScreen(),
            SettingsScreen.route: (ctx) => SettingsScreen(),
            UploadScreen.route: (ctx) => UploadScreen(),
            ProfileScreen.route: (ctx) => ProfileScreen(),
            SearchScreen.route: (ctx) => SearchScreen(),
          },
          onUnknownRoute: (settings) =>
              MaterialPageRoute(builder: (ctx) => TabsScreen()),
        ),
      ),
    );
  }
}
