import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String header;
  final String statement;
  final Function callback;

  ConfirmDialog({this.header, this.statement, this.callback});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(this.header),
      titleTextStyle: TextStyle(color: Theme.of(context).primaryColor),
      content: Container(
        height: 100,
        child: Column(
          children: <Widget>[
            Text(this.statement),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                RaisedButton(
                  color: Colors.red,
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                RaisedButton(
                  color: Colors.green,
                  child: const Text('Ok'),
                  onPressed: this.callback,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
