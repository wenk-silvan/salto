import 'package:flutter/material.dart';
import 'package:salto/components/auth_actions.dart';

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
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
                  SizedBox(height: deviceSize.height * 0.1),
                  AuthActions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
