import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String statement;
  final Function callback;
  final Widget child;
  static const Color textColor = Colors.white;

  ConfirmDialog({@required this.statement, @required this.callback, this.child});

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
      content: this.child == null ? _actionButtonBuilder(context) :
      Container(
        height: MediaQuery.of(context).size.height * 0.4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.3),
              child: this.child,
            ),
            _actionButtonBuilder(context),
          ],
        ),
      )
      ,
    );
  }

  Widget _actionButtonBuilder(BuildContext ctx) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        FlatButton(
            child: Text('Cancel', style: TextStyle(color: textColor)),
            onPressed: () => Navigator.of(ctx).pop()),
        FlatButton(
          child: const Text('Ok', style: TextStyle(color: textColor)),
          onPressed: this.callback,
        ),
      ],
    );
  }
}
