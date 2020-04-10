import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Timestamp extends StatelessWidget {
  DateTime timestamp;

  Timestamp(this.timestamp);

  @override
  Widget build(BuildContext context) {
    return Text(DateFormat('dd.MM.yyyy').format(this.timestamp),
        style: TextStyle(color: Colors.grey, fontSize: 12));
  }
}
