import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:salto/components/auth_actions.dart';

class AuthScreen extends StatelessWidget {
  static const route = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/trampoline_feathers.jpg'),
              fit: BoxFit.cover,
            )
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 50.0,
              right: 10,
              left: 10,
              bottom: 10,
            ),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        'Salto',
                        style: TextStyle(
                          fontSize: 40,
                        ),
                      ),
                      subtitle: Text('Freestyle Trampoline Community App'),
                    ),
                    AuthActions(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
