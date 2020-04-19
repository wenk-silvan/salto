import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salto/providers/auth.dart';
import 'package:salto/providers/comments.dart';
import 'package:salto/providers/content-items.dart';
import 'package:salto/providers/media.dart';
import 'package:salto/providers/users.dart';
import 'package:salto/screens/camera_screen.dart';
import 'package:salto/screens/auth_screen.dart';
import 'package:salto/screens/profile_screen.dart';
import 'package:salto/screens/search_screen.dart';
import 'package:salto/screens/settings_screen.dart';
import 'package:salto/screens/splash_screen.dart';
import 'package:salto/screens/tabs_screen.dart';
import 'package:salto/screens/upload_screen.dart';
import 'package:salto/screens/post_screen.dart';
import 'package:salto/secret.dart';
import 'package:salto/secret_loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  Future<Secret> secret = SecretLoader(secretPath: "secrets.json").load();
  await secret.then((secret) async {
    final FirebaseApp app = await FirebaseApp.configure(
      name: 'test',
      options: FirebaseOptions(
        googleAppID: secret.googleAppID,
        apiKey: secret.apiKey,
        projectID: secret.projectID,
      ),
    );
    final FirebaseStorage storage = FirebaseStorage(
        app: app, storageBucket: secret.storageBucket);
    runApp(MyApp(storage: storage, cameras: cameras,));
  });
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  final FirebaseStorage storage;
  MyApp({this.storage, this.cameras});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Auth()),
        ChangeNotifierProxyProvider<Auth, ContentItems>(
          create: (BuildContext ctx) => null,
          update: (ctx, auth, previousItems) => ContentItems(
            auth.token,
            previousItems == null ? [] : previousItems.items,
          ),
        ),
        ChangeNotifierProxyProvider<Auth, Users>(
          create: (BuildContext ctx) => null,
          update: (ctx, auth, previousUsers) => Users(
            auth.token,
            previousUsers == null ? [] : previousUsers.users,
          ),
        ),
        ChangeNotifierProxyProvider<Auth, Comments>(
          create: (BuildContext ctx) => null,
          update: (ctx, auth, previousComments) => Comments(
            auth.token,
            previousComments == null ? [] : previousComments.items,
          ),
        ),
        ChangeNotifierProxyProvider<Auth, Media>(
          create: (BuildContext ctx) => null,
          update: (ctx, auth, previousMedia) => Media(
            auth.token,
            previousMedia == null ? [] : previousMedia.media,
          ),
        )
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
            SettingsScreen.route: (ctx) => SettingsScreen(),
            UploadScreen.route: (ctx) => UploadScreen(this.storage),
            ProfileScreen.route: (ctx) => ProfileScreen(),
            SearchScreen.route: (ctx) => SearchScreen(),
            AuthScreen.route: (ctx, ) => AuthScreen(),
            PostScreen.route: (ctx) => PostScreen(),
            CameraScreen.route: (ctx) => CameraScreen(cameras: this.cameras),
          },
          onUnknownRoute: (settings) =>
              MaterialPageRoute(builder: (ctx) => TabsScreen()),
        ),
      ),
    );
  }
}
