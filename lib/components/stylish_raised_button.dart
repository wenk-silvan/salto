import 'package:flutter/material.dart';

class StylishRaisedButton extends StatelessWidget {
  final Function callback;
  final Widget child;

  StylishRaisedButton({this.callback, this.child});

  @override
  Widget build(BuildContext context) {
    return
      RaisedButton(
        onPressed: this.callback,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        child: Container(
          height: 50,
          child: Center(child: child),
        ),
        color: Theme.of(context).accentColor,
      );
  }
}
