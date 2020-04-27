import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String statement;
  final Function callback;
  static const Color textColor = Colors.white;

  ConfirmDialog({this.statement, this.callback});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      title: Text(
        this.statement,
        style: TextStyle(fontSize: 20),
      ),
      titleTextStyle: TextStyle(color: textColor),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FlatButton(
              child: Text('Cancel', style: TextStyle(color: textColor)),
              onPressed: () => Navigator.of(context).pop()),
          FlatButton(
            child: const Text('Ok', style: TextStyle(color: textColor)),
            onPressed: this.callback,
          ),
        ],
      ),
    );
  }
}
