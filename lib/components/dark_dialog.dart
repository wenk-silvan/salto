import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salto/providers/auth.dart';

class DarkDialog extends StatelessWidget {
  final String statement;
  final Widget content;
  final bool brightMode;

  DarkDialog({this.content, this.statement, this.brightMode});

  @override
  Widget build(BuildContext context) {
    if (!Provider.of<Auth>(context).isAuth) {
      Navigator.of(context).pop();
    }
    final textColor = this.brightMode ? Colors.black : Colors.white;
    return AlertDialog(
      backgroundColor: this.brightMode ? Colors.white : Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      title: Text(
        this.statement,
        style: TextStyle(fontSize: 20, color: textColor),
      ),
      titleTextStyle: TextStyle(color: textColor),
      content: this.content,
    );
  }
}
